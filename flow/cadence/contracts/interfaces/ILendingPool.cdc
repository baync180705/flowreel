import "FungibleToken"
import "LoanTypes"

/// ILendingPool
///
/// Interface for the lending pool system
/// Provides low-collateral loans to verified creators
///
access(all) contract interface ILendingPool {

    /// Events
    access(all) event LoanApplicationSubmitted(
        applicationId: UInt64,
        applicant: Address,
        amount: UFix64,
        timestamp: UFix64
    )
    access(all) event LoanApproved(
        loanId: UInt64,
        borrower: Address,
        amount: UFix64,
        timestamp: UFix64
    )
    access(all) event LoanDisbursed(
        loanId: UInt64,
        borrower: Address,
        amount: UFix64,
        timestamp: UFix64
    )
    access(all) event LoanRepaymentMade(
        loanId: UInt64,
        borrower: Address,
        amount: UFix64,
        remainingBalance: UFix64,
        timestamp: UFix64
    )
    access(all) event LoanFullyRepaid(
        loanId: UInt64,
        borrower: Address,
        totalRepaid: UFix64,
        timestamp: UFix64
    )
    access(all) event LoanDefaulted(
        loanId: UInt64,
        borrower: Address,
        outstandingAmount: UFix64,
        timestamp: UFix64
    )
    access(all) event LoanLiquidated(
        loanId: UInt64,
        borrower: Address,
        collateralSeized: UFix64,
        timestamp: UFix64
    )
    access(all) event CollateralDeposited(
        loanId: UInt64,
        borrower: Address,
        amount: UFix64,
        timestamp: UFix64
    )
    access(all) event CollateralReturned(
        loanId: UInt64,
        borrower: Address,
        amount: UFix64,
        timestamp: UFix64
    )

    /// Get loan information
    access(all) fun getLoanInfo(loanId: UInt64): LoanTypes.LoanInfo?

    /// Get all active loans for a borrower
    access(all) fun getBorrowerLoans(borrower: Address): [UInt64]

    /// Get lending pool statistics
    /// Returns dictionary with keys: totalLoaned, totalRepaid, activeLoans, defaultedLoans, 
    /// availableLiquidity, totalCollateral, averageInterestRate
    access(all) fun getPoolStats(): {String: AnyStruct}

    /// Check if an address is eligible for a loan
    access(all) fun isEligibleForLoan(address: Address, amount: UFix64): Bool

    /// Calculate loan interest
    access(all) fun calculateInterest(principal: UFix64, rate: UFix64, duration: UFix64): UFix64

    /// Get default interest rate for creator loans
    access(all) fun getDefaultCreatorLoanRate(): UFix64

    /// Get minimum collateral ratio
    access(all) fun getMinimumCollateralRatio(): UFix64
}