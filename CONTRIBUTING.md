# Contributing to Smart Factory PiAI

First off, thank you for considering contributing to PiAI! It's people like you that make this project valuable for the entire community.

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check the [issue tracker](https://github.com/dougrichards13/PiAI/issues) to see if the problem has already been reported.

When creating a bug report, please include:
- **Description**: Clear description of the issue
- **Steps to Reproduce**: Detailed steps to reproduce the problem
- **Expected Behavior**: What you expected to happen
- **Actual Behavior**: What actually happened
- **Environment**: 
  - Raspberry Pi model and RAM
  - OS version (`cat /etc/os-release`)
  - Ollama version (`ollama --version`)
  - Python version (`python3 --version`)
- **Logs**: Relevant error messages or logs

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion, please include:
- **Clear title and description**
- **Why this enhancement would be useful** to most users
- **Possible implementation** (if you have ideas)
- **Examples** from other projects (if applicable)

### Pull Requests

1. **Fork the repository** and create your branch from `main`:
   ```bash
   git checkout -b feature/amazing-feature
   ```

2. **Make your changes**:
   - Follow the existing code style
   - Add comments for complex logic
   - Update documentation as needed

3. **Test your changes**:
   - Ensure all existing functionality still works
   - Test on actual Raspberry Pi 5 if possible
   - Run the AI helper: `./ai-helper.sh status`

4. **Commit your changes**:
   ```bash
   git commit -m "Add amazing feature"
   ```
   
   Use clear, descriptive commit messages:
   - `feat:` for new features
   - `fix:` for bug fixes
   - `docs:` for documentation changes
   - `refactor:` for code refactoring
   - `test:` for test additions

5. **Push to your fork**:
   ```bash
   git push origin feature/amazing-feature
   ```

6. **Open a Pull Request** with:
   - Clear title and description
   - Reference to related issues (if any)
   - Screenshots/videos (if applicable)
   - Testing results

## Development Setup

1. Clone your fork:
   ```bash
   git clone https://github.com/YOUR-USERNAME/PiAI.git
   cd PiAI
   ```

2. Set up the development environment:
   ```bash
   ./scripts/install.sh
   ```

3. Make changes and test locally

## Code Style Guidelines

### Python
- Follow [PEP 8](https://www.python.org/dev/peps/pep-0008/)
- Use meaningful variable names
- Add docstrings to functions
- Keep functions focused and small

### Bash Scripts
- Use `#!/bin/bash` shebang
- Add comments for complex logic
- Use `set -e` for error handling
- Quote variables: `"$VARIABLE"`

### Documentation
- Use clear, concise language
- Include code examples where helpful
- Target beginners (explain acronyms, etc.)
- Use proper Markdown formatting

## Example Projects

When contributing example projects:

1. **Create a dedicated directory**:
   ```
   examples/your-project/
   ├── README.md
   ├── main_script.py
   └── requirements.txt (if needed)
   ```

2. **Include a comprehensive README** with:
   - Project description
   - Prerequisites
   - Installation steps
   - Usage instructions
   - Troubleshooting section
   - Credits/acknowledgments

3. **Test thoroughly** on Raspberry Pi 5

4. **Keep dependencies minimal** - use what's already installed when possible

## Documentation Contributions

Documentation improvements are always welcome!

- Fix typos or clarify confusing sections
- Add missing information
- Improve examples
- Translate documentation (coming soon)

## Community Guidelines

### Be Respectful
- Use welcoming and inclusive language
- Be respectful of differing viewpoints
- Gracefully accept constructive criticism
- Focus on what is best for the community

### Be Collaborative
- Seek feedback early and often
- Share knowledge and credit others
- Help newcomers get started
- Be patient with questions

### Be Professional
- Keep discussions on-topic
- Avoid inflammatory language
- Don't spam or self-promote excessively
- Respect maintainer decisions

## Recognition

Contributors will be:
- Listed in project documentation
- Credited in release notes
- Featured in the Smart Factory showcase (with permission)

Significant contributors may be offered co-maintainer status.

## Questions?

- **GitHub Discussions**: [Ask questions](https://github.com/dougrichards13/PiAI/discussions)
- **Issues**: [Report bugs or suggest features](https://github.com/dougrichards13/PiAI/issues)
- **Smart Factory Community**: [Join the forum](https://smartfactory.io/community)

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

**Thank you for making PiAI better for everyone!** 🎉

*— The Smart Factory Team*
