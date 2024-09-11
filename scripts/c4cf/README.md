# c4cf - Checking For Changed Files

## Description

Sometimes it's useful to figure what files have changed on your system. For example, you might want to know what a software upgrade actually touched. Other times you want to make sure that files on your system don't change. For example, system-critical configuration files or commands should remain intact. Changes in these files can indicate that your system has been hacked.

This script checks a filesystem and reports any changes made since the last time it was run.

## Dependencies

- [Text::ASCIITable](https://metacpan.org/pod/Text::ASCIITable)

## Usage

```bash
perl c4cf.pl [OPTIONS]
```