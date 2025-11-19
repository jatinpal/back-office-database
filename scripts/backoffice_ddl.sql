-- Investment Bank Back-Office Database
-- Complete DDL Script with VARCHAR IDs and Uppercase ENUMs

-- Create Database
DROP DATABASE IF EXISTS backoffice;
CREATE DATABASE backoffice;
USE backoffice;

-- Create Tables

CREATE TABLE Client (
    client_id VARCHAR(10) PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    middle_name VARCHAR(50),
    last_name VARCHAR(50),
    country VARCHAR(50) NOT NULL,
    client_type ENUM('INDIVIDUAL', 'INSTITUTIONAL') NOT NULL,
    client_status ENUM('ACTIVE', 'INACTIVE', 'SUSPENDED') NOT NULL DEFAULT 'ACTIVE',
    tax_id VARCHAR(20) UNIQUE NOT NULL
);

CREATE TABLE User (
    user_id VARCHAR(5) PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    middle_name VARCHAR(50),
    last_name VARCHAR(100) NOT NULL,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(50) UNIQUE NOT NULL,
    department VARCHAR(50) NOT NULL,
    role VARCHAR(50) NOT NULL,
    last_login DATETIME
);

CREATE TABLE Counterparty (
    counterparty_id VARCHAR(5) PRIMARY KEY,
    counterparty_name VARCHAR(100) NOT NULL,
    counterparty_type VARCHAR(50) NOT NULL,
    credit_limit DECIMAL(15, 2),
    settlement_instructions TEXT
);

CREATE TABLE Security (
    cusip CHAR(9) PRIMARY KEY,
    symbol VARCHAR(10) NOT NULL,
    security_name VARCHAR(100) NOT NULL,
    security_type ENUM('EQUITY', 'BOND', 'ETF') NOT NULL,
    exchange VARCHAR(50) NOT NULL,
    INDEX idx_symbol (symbol),
    INDEX idx_security_type (security_type)
);

CREATE TABLE Account (
    account_id VARCHAR(15) PRIMARY KEY,
    client_id VARCHAR(10) NOT NULL,
    opening_date DATE NOT NULL,
    account_type ENUM('CASH', 'MARGIN', 'RETIREMENT') NOT NULL,
    status ENUM('ACTIVE', 'INACTIVE', 'FROZEN') NOT NULL DEFAULT 'ACTIVE',
    manager_id VARCHAR(5) NOT NULL,
    FOREIGN KEY (client_id) REFERENCES Client(client_id),
    FOREIGN KEY (manager_id) REFERENCES User(user_id),
    INDEX idx_client_id (client_id),
    INDEX idx_manager_id (manager_id)
);

CREATE TABLE Bond (
    cusip CHAR(9) PRIMARY KEY,
    face_value DECIMAL(15, 2) NOT NULL,
    coupon_rate DECIMAL(5, 4) NOT NULL,
    maturity_date DATE NOT NULL,
    issue_date DATE,
    FOREIGN KEY (cusip) REFERENCES Security(cusip) ON DELETE CASCADE
);

CREATE TABLE Trade (
    trade_id VARCHAR(50) PRIMARY KEY,
    account_id VARCHAR(15) NOT NULL,
    cusip CHAR(9) NOT NULL,
    counterparty_id VARCHAR(5) NOT NULL,
    transaction_type ENUM('BUY', 'SELL') NOT NULL,
    price DECIMAL(10, 4) NOT NULL,
    units INT NOT NULL,
    trade_date DATETIME NOT NULL,
    settlement_date DATE,
    status ENUM('PENDING', 'SETTLED', 'CANCELLED', 'FAILED') NOT NULL DEFAULT 'SETTLED',
    FOREIGN KEY (account_id) REFERENCES Account(account_id),
    FOREIGN KEY (cusip) REFERENCES Security(cusip),
    FOREIGN KEY (counterparty_id) REFERENCES Counterparty(counterparty_id),
    INDEX idx_trade_date (trade_date),
    INDEX idx_settlement_date (settlement_date),
    INDEX idx_account_trade (account_id, trade_date)
);

CREATE TABLE Lot (
    lot_id VARCHAR(5) PRIMARY KEY,
    trade_id VARCHAR(50) NOT NULL,
    account_id VARCHAR(15) NOT NULL,
    cusip CHAR(9) NOT NULL,
    units INT NOT NULL,
    cost_basis DECIMAL(15, 4) NOT NULL,
    acquisition_date DATE NOT NULL,
    FOREIGN KEY (trade_id) REFERENCES Trade(trade_id),
    FOREIGN KEY (account_id) REFERENCES Account(account_id),
    FOREIGN KEY (cusip) REFERENCES Security(cusip),
    INDEX idx_trade_id (trade_id)
);

CREATE TABLE Journal (
    journal_id VARCHAR(50) PRIMARY KEY,
    trade_id VARCHAR(50),
    account_id VARCHAR(15) NOT NULL,
    journal_type ENUM('DEBIT', 'CREDIT') NOT NULL,
    amount DECIMAL(15, 2) NOT NULL,
    entry_date DATE NOT NULL,
    FOREIGN KEY (trade_id) REFERENCES Trade(trade_id),
    FOREIGN KEY (account_id) REFERENCES Account(account_id),
    INDEX idx_trade_id (trade_id)
);

CREATE TABLE Position (
    account_id VARCHAR(15) NOT NULL,
    cusip CHAR(9) NOT NULL,
    as_of_date DATE NOT NULL,
    units INT NOT NULL,
    PRIMARY KEY (account_id, cusip, as_of_date),
    FOREIGN KEY (account_id) REFERENCES Account(account_id),
    FOREIGN KEY (cusip) REFERENCES Security(cusip)
);

CREATE TABLE CorporateAction (
    action_id VARCHAR(50) PRIMARY KEY,
    cusip CHAR(9) NOT NULL,
    action_type ENUM('DIVIDEND', 'SPLIT', 'MERGER', 'SPINOFF', 'NAME_CHANGE', 'SYMBOL_CHANGE', 'DELISTING') NOT NULL,
    ex_date DATE,
    record_date DATE,
    pay_date DATE,
    adjustment_factor DECIMAL(10, 6),
    new_security_name VARCHAR(100),
    new_symbol VARCHAR(10),
    FOREIGN KEY (cusip) REFERENCES Security(cusip),
    INDEX idx_cusip_action (cusip, action_type)
);

CREATE TABLE MarketData (
    cusip CHAR(9) NOT NULL,
    price_date DATE NOT NULL,
    open_price DECIMAL(10, 4),
    close_price DECIMAL(10, 4) NOT NULL,
    daily_high DECIMAL(10, 4),
    daily_low DECIMAL(10, 4),
    volume BIGINT,
    PRIMARY KEY (cusip, price_date),
    FOREIGN KEY (cusip) REFERENCES Security(cusip)
);

-- Verify tables created
SHOW TABLES;