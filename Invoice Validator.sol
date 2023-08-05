// SPDX-License-Identifier: UNLICENCED
pragma solidity ^0.8.12;

contract InvoiceValidation {
    // Structure to store invoice details
    struct Invoice {
        address supplier;
        address recipient;
        uint256 amount;
        string transactionType;
        bool isPaid;
        bool isValidated;
    }

    // Mapping to store invoice ID to Invoice struct
    mapping(uint256 => Invoice) public invoices;

    // Event to notify when an invoice is submitted and validated
    event InvoiceSubmitted(uint256 indexed invoiceId, address indexed supplier);

    // Modifier to restrict access to only tax authorities
    modifier onlyTaxAuthority() {
        // Add your logic here to verify that the sender is a tax authority
        _;
    }

    // Function to submit an invoice for validation
    function submitInvoice(
        uint256 invoiceId,
        address recipient,
        uint256 amount,
        string memory transactionType
    ) external {
        // Check if the invoice with given ID already exists
        require(!invoices[invoiceId].isValidated, "Invoice already validated");

        // Check if the invoice number is not empty
        bytes memory invoiceNumberBytes = bytes(transactionType);
        require(invoiceNumberBytes.length > 0, "Invoice number cannot be empty");

        // Create a new invoice and store it in the mapping
        invoices[invoiceId] = Invoice({
            supplier: msg.sender,
            recipient: recipient,
            amount: amount,
            transactionType: transactionType,
            isPaid: false,
            isValidated: false
        });

        // Emit an event to notify the submission of the invoice
        emit InvoiceSubmitted(invoiceId, msg.sender);
    }

    // Function to validate an invoice
    function validateInvoice(uint256 invoiceId) external onlyTaxAuthority {
        // Check if the invoice exists and is not already validated
        require(!invoices[invoiceId].isValidated, "Invoice already validated");

        // Add your logic here to verify the authenticity of the transaction

        // Mark the invoice as validated
        invoices[invoiceId].isValidated = true;
    }

    // Function to pay a validated invoice
    function payInvoice(uint256 invoiceId) external payable {
        // Check if the invoice exists and is validated
        require(invoices[invoiceId].isValidated, "Invoice not validated");

        // Check if the invoice is not already paid
        require(!invoices[invoiceId].isPaid, "Invoice already paid");

        // Check if the amount sent matches the invoice amount
        require(msg.value == invoices[invoiceId].amount, "Incorrect payment amount");

        // Mark the invoice as paid
        invoices[invoiceId].isPaid = true;

        // Transfer the payment to the supplier
        payable(invoices[invoiceId].supplier).transfer(msg.value);
    }

    // Function to check if an invoice is valid
    function isInvoiceValid(uint256 invoiceId) external view returns (bool) {
        return invoices[invoiceId].isValidated;
    }
}
