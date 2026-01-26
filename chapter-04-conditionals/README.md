# Chapter 04 - Conditionals

Master conditional task execution in Ansible - control when and how tasks run.

## What You'll Learn

- Basic `when` conditionals with variables and facts
- Multiple conditions (AND / OR)
- Using `when` with registered variables
- `failed_when` and `changed_when`
- Conditionals in loops and blocks

---

## Quick Start

```bash
cd chapter-04-conditionals
ansible all -m ping
ansible-playbook 01-when-basics.yml
```

---

## Playbooks

| # | Playbook | Concepts Covered |
|---|----------|------------------|
| 01 | when-basics.yml | Basic when, facts, variables, comparisons |
| 02 | multiple-conditions.yml | AND (list), OR, complex conditions |
| 03 | when-with-register.yml | Decisions based on task results |
| 04 | failed-changed-when.yml | Custom failure/change conditions |
| 05 | conditionals-loops-blocks.yml | Conditionals in loops and blocks |

---

## Run the Playbooks

### Playbook 01: When Basics

```bash
ansible-playbook 01-when-basics.yml
ansible-playbook 01-when-basics.yml -e "deploy_env=staging"
```

**Covers:** Boolean checks, string comparison, `in` operator, facts (OS, memory), group membership, `is defined`

---

### Playbook 02: Multiple Conditions

```bash
ansible-playbook 02-multiple-conditions.yml
```

**Covers:** AND (YAML list), OR (`or` keyword), complex conditions, version comparison

---

### Playbook 03: When with Register

```bash
ansible-playbook 03-when-with-register.yml
```

**Covers:** File existence check, command return codes, output parsing, `changed` status

---

### Playbook 04: failed_when & changed_when

```bash
ansible-playbook 04-failed-changed-when.yml
```

**Covers:** Custom failure conditions, never fail, custom change detection, idempotency

---

### Playbook 05: Conditionals with Loops & Blocks

```bash
ansible-playbook 05-conditionals-loops-blocks.yml
```

**Covers:** Filter loop items, blocks with conditions, OS-specific blocks

---

## Quick Reference

### Comparison Operators

| Operator | Example |
|----------|---------|
| `==` | `when: env == "prod"` |
| `!=` | `when: env != "dev"` |
| `>`, `<`, `>=`, `<=` | `when: count > 5` |
| `in` | `when: item in list` |
| `not in` | `when: item not in list` |

### Jinja2 Tests

| Test | Example |
|------|---------|
| `is defined` | `when: var is defined` |
| `is not defined` | `when: var is not defined` |
| `is version()` | `when: ver is version('2.0', '>=')` |

### Multiple Conditions

```yaml
# AND - all must be true (list format)
when:
  - condition1
  - condition2

# OR - any can be true
when: condition1 or condition2
```

### failed_when / changed_when

```yaml
# Custom failure
failed_when: result.rc != 0 or 'ERROR' in result.stdout

# Never report changed (read-only commands)
changed_when: false

# Change based on output
changed_when: "'CREATED' in result.stdout"
```

---

## Key Takeaways

1. **when** - Skip tasks based on conditions
2. **AND** - Use YAML list format
3. **OR** - Use `or` keyword
4. **Register** - Make decisions from task results
5. **failed_when** - Custom failure conditions
6. **changed_when** - Control change reporting
7. **Blocks** - Apply one condition to many tasks
