
# Blockchain Bootcamp

Welcome to the **Blockchain Bootcamp**! This repository is a collection of projects we created to share our journey through blockchain learning and development. Our goal is to help others learn and experiment with the tools, frameworks, and concepts that we found most useful while building decentralized applications (dApps).

Whether you're new to blockchain or looking to deepen your understanding of Solidity, Foundry, and Ethereum tooling, you'll find practical examples and real-world use cases here.

---

## Why We Built This

As blockchain developers, we encountered challenges while learning how to build secure and efficient smart contracts. This repository is our way of documenting those lessons and providing a resource for others to:
- Learn blockchain development with practical examples.
- Understand common use cases like licensing and token-based payments.
- Explore tools like Alchemy, Foundry, and Etherscan for deploying, testing, and verifying contracts.

---

## What You'll Find

### 1. **Alchemy Academy Examples**
- **Folder:** `alchemy/`
- **What It Covers:**
  - Great exercises from the Alchemy Academy course.

---

### 2. **License Demo (ETH Payments)**
- **Folder:** `license-demo-eth/`
- **What It Covers:**
  - A licensing system where users pay in native ETH to buy licenses.
  - Features include license management, transfers, and revenue sharing.

---

### 3. **License Demo (ERC-20 Tokens)**
- **Folder:** `license-demo-token/`
- **What It Covers:**
  - A token-based version of the licensing system using ERC-20 tokens.
  - Learn how to handle allowances, token transfers, and balances.

---

### 4. **Piggybank Contract**
- **Folder:** `piggybank/`
- **What It Covers:**
  - A savings contract where users can deposit and withdraw ETH.
  - Demonstrates basic financial contract functionality.

---

### 5. **Contract Verification**
- **Folder:** `verify-tester/`
- **What It Covers:**
  - Scripts and workflows for verifying messages coming from external sources such as oracles to smart contracts.

---

## How to Get Started

### Prerequisites

1. **Install Foundry**
   - Foundry is the main toolkit we used for developing and testing smart contracts.
   ```bash
   curl -L https://foundry.paradigm.xyz | bash
   foundryup
   ```

2. **Install Dependencies**
   - Clone this repository and navigate to the folder:
   ```bash
   git clone https://github.com/aidamian/blockchain-bootcamp.git
   cd blockchain-bootcamp
   ```

3. **Set Up a New Project (Optional)**
   - You can create your own Foundry-based project if you'd like to build from scratch:
   ```bash
   forge init --force
   forge new my-project
   ```

---

### Running the Examples

1. **Run Tests**
   - We've written comprehensive tests for each contract to ensure functionality and teach best practices.
   ```bash
   forge test
   ```

2. **Deploy Smart Contracts**
   - Use Foundry's built-in tools to deploy contracts or integrate with Alchemy for advanced deployment workflows.

3. **Interact with Contracts**
   - After deployment, use scripts or Foundry's console to interact with the contracts.

---

## Our Vision

Blockchain technology is transformative, but learning it can be intimidating. By providing these examples, we aim to:
- Simplify complex blockchain concepts.
- Equip developers with practical knowledge to build their own dApps.
- Foster an open-source mindset where developers learn and grow together.

---

## Contributing

We welcome contributions from the community! If you have ideas to improve this repository or want to add new examples, feel free to:
1. Fork the repository.
2. Create a branch for your changes.
3. Submit a pull request with a detailed explanation.

---

## License

This project is licensed under the [Apache-2.0 License](LICENSE).

---

## Acknowledgments

We'd like to thank the open-source community for providing tools, frameworks, and inspiration that made this project possible. Special thanks to:
- [Foundry](https://book.getfoundry.sh/)
- [Alchemy](https://www.alchemy.com/)
- [Alchemy Academy](https://academy.alchemy.com/)
- [OpenZeppelin](https://docs.openzeppelin.com/)
- [Etherscan](https://etherscan.io/)
- [Solidity](https://docs.soliditylang.org/)

Let's build the decentralized future together!


## Citation

If you found this repository helpful, please consider citing it as:

```bibtex
@misc{blockchain-bootcamp,
  author = {Andrei Damian},
  title = {Blockchain Bootcamp},
  year = {2024},
  publisher = {GitHub},
  journal = {GitHub repository},
  howpublished = {\url{https://github.com/aidamian/blockchain-bootcamp}}
} 
```