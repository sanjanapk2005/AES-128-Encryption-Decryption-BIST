# AES-128 Encryption and Decryption with Built-In Self-Test (BIST)

## Project Overview

This project implements an AES-128 (Advanced Encryption Standard) cryptographic system with integrated Built-In Self-Test (BIST) functionality using Verilog HDL and Cadence EDA tools.

The design supports both encryption and decryption operations and incorporates BIST techniques to evaluate the functionality and fault detection capability of the AES architecture.

An LFSR (Linear Feedback Shift Register) is used for test-pattern generation, while an MISR (Multiple Input Signature Register) is used for response signature analysis.

## Objectives

- Design and implement AES-128 encryption and decryption using Verilog HDL.
- Integrate Built-In Self-Test functionality into the AES architecture.
- Generate test patterns using an LFSR.
- Analyse test responses using an MISR.
- Perform fault injection to evaluate fault detection capability.
- Verify the design through RTL simulation and synthesis using Cadence tools.

## Design Modules

- **AES Encryption:** Performs 128-bit plaintext encryption using a 128-bit secret key.
- **AES Decryption:** Recovers the original plaintext from the encrypted ciphertext.
- **LFSR:** Generates test patterns for BIST operation.
- **MISR:** Compacts test responses into a signature.
- **BIST:** Performs self-testing and evaluates the generated signature.
- **Fault Injection:** Introduces faults to evaluate the fault detection mechanism.

## Technologies and Tools

| Category | Technology |
|---|---|
| Hardware Description Language | Verilog HDL |
| Simulation | Cadence SimVision / NC-Sim |
| Synthesis | Cadence Genus |
| Design | AES-128 and BIST |
| Constraints | SDC |

## Simulation and Verification

The design was verified using Verilog testbenches through Cadence simulation tools.

The following test cases were performed:

| Test Case | Simulation Result |
|---|---|
| AES-128 Encryption | PASS |
| AES-128 Decryption | PASS |
| Normal BIST | PASS |
| Fault Injection | Fault successfully detected |

### AES-128 Encryption Verification

- Key: `000102030405060708090A0B0C0D0E0F`
- Plaintext: `00112233445566778899AABBCCDDEEFF`
- Expected Ciphertext: `69C4E0D86A7B0430D8CDB78070B4C55A`

The simulation successfully generated the expected ciphertext.

### AES-128 Decryption Verification

The decryption module successfully recovered the original plaintext from the encrypted ciphertext.

### BIST Verification

The normal BIST test generated a matching MISR signature and passed the signature comparison.

During fault injection, the generated signature differed from the expected signature, allowing the fault detection mechanism to identify the injected fault.

## Synthesis and Analysis

RTL synthesis was performed using Cadence Genus.

The repository includes:
- Area reports
- Power reports
- Timing reports

## Repository Structure

```text
AES-128-Encryption-Decryption-BIST/
│
├── RTL/
│
├── TESTBENCH/
│
├── REPORTS/
│
├── CONSTRAINTS/
│
├── SIMULATION_RESULTS/
│
└── README.md

## Key Learning Outcomes

- Understanding AES-128 encryption and decryption architecture.
- RTL design and verification using Verilog HDL.
- Understanding Built-In Self-Test architecture.
- LFSR-based test-pattern generation.
- MISR-based signature analysis.
- Fault injection and fault detection.
- Working with Cadence EDA tools for simulation and synthesis.

## Author

**Sanjana P. Kulkarni**

Electronics and Communication Engineering

Areas of Interest: VLSI Design, ASIC Design and Verification.
