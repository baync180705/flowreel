/// LoanTypes
///
/// Defines all loan-related structs and enums for the FlowReel lending system
///
access(all) contract LoanTypes {

    /// LoanStatus
    ///
    /// Enum defining the current status of a loan
    ///
    access(all) enum LoanStatus: UInt8 {
        access(all) case Pending
        access(all) case Active
        access(all) case Repaid
        access(all) case Defaulted
        access(all) case Liquidated
    }

    /// CollateralType
    ///
    /// Enum defining types of collateral accepted
    ///
    access(all) enum CollateralType: UInt8 {
        access(all) case GVT
        access(all) case NFT
        access(all) case Mixed
    }

    /// LoanTerms
    ///
    /// Struct defining the terms of a loan
    ///
    access(all) struct LoanTerms {
        access(all) let principal: UFix64
        access(all) let interestRate: UFix64 // Annual percentage rate
        access(all) let duration: UFix64 // Duration in seconds
        access(all) let collateralRatio: UFix64 // Minimum collateral ratio (e.g., 1.5 = 150%)
        access(all) let liquidationThreshold: UFix64 // Ratio at which liquidation occurs
        access(all) let collateralType: CollateralType

        init(
            principal: UFix64,
            interestRate: UFix64,
            duration: UFix64,
            collateralRatio: UFix64,
            liquidationThreshold: UFix64,
            collateralType: CollateralType
        ) {
            pre {
                principal > 0.0: "Principal must be greater than zero"
                interestRate >= 0.0: "Interest rate cannot be negative"
                duration > 0.0: "Duration must be greater than zero"
                collateralRatio >= 1.0: "Collateral ratio must be at least 1.0"
                liquidationThreshold < collateralRatio: "Liquidation threshold must be less than collateral ratio"
            }

            self.principal = principal
            self.interestRate = interestRate
            self.duration = duration
            self.collateralRatio = collateralRatio
            self.liquidationThreshold = liquidationThreshold
            self.collateralType = collateralType
        }
    }

    /// LoanInfo
    ///
    /// Struct containing information about an active loan
    ///
    access(all) struct LoanInfo {
        access(all) let loanId: UInt64
        access(all) let borrower: Address
        access(all) let terms: LoanTerms
        access(all) let collateralAmount: UFix64
        access(all) let startTime: UFix64
        access(all) let dueDate: UFix64
        access(all) var amountRepaid: UFix64
        access(all) var status: LoanStatus
        access(all) var lastPaymentTime: UFix64?

        init(
            loanId: UInt64,
            borrower: Address,
            terms: LoanTerms,
            collateralAmount: UFix64
        ) {
            pre {
                collateralAmount >= terms.principal * terms.collateralRatio: "Insufficient collateral"
            }

            self.loanId = loanId
            self.borrower = borrower
            self.terms = terms
            self.collateralAmount = collateralAmount
            self.startTime = getCurrentBlock().timestamp
            self.dueDate = self.startTime + terms.duration
            self.amountRepaid = 0.0
            self.status = LoanStatus.Active
            self.lastPaymentTime = nil
        }

        /// Calculate total amount due including interest
        access(all) fun getTotalDue(): UFix64 {
            let interest = self.terms.principal * self.terms.interestRate / 100.0
            return self.terms.principal + interest
        }

        /// Calculate remaining amount to be repaid
        access(all) fun getRemainingDue(): UFix64 {
            let totalDue = self.getTotalDue()
            return totalDue - self.amountRepaid
        }

        /// Check if loan is overdue
        access(all) fun isOverdue(): Bool {
            return getCurrentBlock().timestamp > self.dueDate && self.status == LoanStatus.Active
        }

        /// Calculate current collateral ratio
        access(all) fun getCurrentCollateralRatio(): UFix64 {
            let remainingDue = self.getRemainingDue()
            if remainingDue == 0.0 {
                return 0.0
            }
            return self.collateralAmount / remainingDue
        }

        /// Check if loan can be liquidated
        access(all) fun canBeLiquidated(): Bool {
            return self.getCurrentCollateralRatio() <= self.terms.liquidationThreshold && self.status == LoanStatus.Active
        }
    }

    /// RepaymentSchedule
    ///
    /// Struct for tracking repayment schedule
    ///
    access(all) struct RepaymentSchedule {
        access(all) let loanId: UInt64
        access(all) let installments: [Installment]
        access(all) var currentInstallment: Int

        init(loanId: UInt64, numberOfInstallments: Int, totalAmount: UFix64, startTime: UFix64, interval: UFix64) {
            self.loanId = loanId
            self.installments = []
            self.currentInstallment = 0

            let amountPerInstallment = totalAmount / UFix64(numberOfInstallments)
            var i = 0
            while i < numberOfInstallments {
                let dueDate = startTime + (interval * UFix64(i + 1))
                self.installments.append(Installment(
                    installmentNumber: i + 1,
                    amount: amountPerInstallment,
                    dueDate: dueDate,
                    paid: false
                ))
                i = i + 1
            }
        }
    }

    /// Installment
    ///
    /// Struct representing a single loan installment
    ///
    access(all) struct Installment {
        access(all) let installmentNumber: Int
        access(all) let amount: UFix64
        access(all) let dueDate: UFix64
        access(all) var paid: Bool
        access(all) var paidDate: UFix64?

        init(installmentNumber: Int, amount: UFix64, dueDate: UFix64, paid: Bool) {
            self.installmentNumber = installmentNumber
            self.amount = amount
            self.dueDate = dueDate
            self.paid = paid
            self.paidDate = nil
        }
    }

    /// LoanApplication
    ///
    /// Struct for loan applications pending approval
    ///
    access(all) struct LoanApplication {
        access(all) let applicationId: UInt64
        access(all) let applicant: Address
        access(all) let requestedAmount: UFix64
        access(all) let proposedCollateral: UFix64
        access(all) let purpose: String
        access(all) let requestedTerms: LoanTerms
        access(all) let appliedAt: UFix64
        access(all) var approved: Bool?

        init(
            applicationId: UInt64,
            applicant: Address,
            requestedAmount: UFix64,
            proposedCollateral: UFix64,
            purpose: String,
            requestedTerms: LoanTerms
        ) {
            pre {
                purpose.length > 0 && purpose.length <= 500: "Purpose must be 1-500 characters"
            }

            self.applicationId = applicationId
            self.applicant = applicant
            self.requestedAmount = requestedAmount
            self.proposedCollateral = proposedCollateral
            self.purpose = purpose
            self.requestedTerms = requestedTerms
            self.appliedAt = getCurrentBlock().timestamp
            self.approved = nil
        }
    }

    init() {}
}