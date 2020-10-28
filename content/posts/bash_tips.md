---
title: "Simple Tips for Happy Bashing"
date: 2020-10-03T23:31:23+10:00
draft: false
Author: "Daniel Barrett"
---

[Bash (Bourne Again Shell)](https://en.wikipedia.org/wiki/Bash_(Unix_shell)) is an incredibly common shell and scripting language in which any developer working on Linux and macOS based systems will inevitably come across. Because of this, Bash scripting skills are a formidible tool to have in your belt. However, Bash scripting is notoriously difficult due to its extensive nature and large feature set, which often leads to developers writing poor scripts.

In this post, we will how explore you can write better Bash scripts with the help of `The Set Builtin`, `Trapping Functions`, `Shellcheck`, and `Idempotency`.

---
## The Set Builtin
The [builtin set command](https://www.gnu.org/software/bash/manual/html_node/The-Set-Builtin.html) allows you to change the way the Bash interpreter behaves by providing different flags to the set command. I want to focus on just four of these flags: e, u, o, and x.

Running `set -e` in your script will cause the Bash script to exit as soon as any of the commands in the script exit with a non-zero exit code. This is particularly useful when you need to fail fast and exit ASAP since the default Bash scripting behaviour is to continue.

Running `set -u` will cause an error if any unset variables are expanded. Ordinarily, Bash will just expand an unset variable to an empty string, but this can lead to bugs going undetected in scripts.

Running `set -o pipefail` will cause the exit code of the script to be the last non-zero exit code from a command in the script, and only in the case where all commands exit zero, then the script will also exit zero.

Running `set -x` will print a trace of the commands being run. This is particularly useful when you are debugging a script and need to work out precisely what command was being run. However, this can be annoying since it causes superfluous output.

All of these commands together will look like `set -euxo pipefail` which is often seen directly under the [shebang](https://en.wikipedia.org/wiki/Shebang_(Unix)). To disable these changes, simply use `set +<flag>`.

---
## Trapping Functions
Good little Bash scripts should always clean up after themselves when they are complete, however, as good developers we need to make sure we tell them to. Whilst it is simple to write a script that cleans up at the end, you need to also accommodate the scenario where the script my exit early due to a signal to exit or a crash. 

To solve this problem we use the `TRAP cleanup EXIT` pattern. The pattern is explained in great length in [this article here](https://www.linuxjournal.com/content/bash-trap-command), so I will only briefly show an example:
```bash
function cleanup() {
    # some commands
}
trap cleanup SIGINT
trap cleanup EXIT
```
A script with the above code snippet will run the cleanup function on either the `EXIT` or `SIGINT` signal, therefore we do not need to actually call the `cleanup` function directly in the script once we have included this trap, or else it will be invoked twice.

A handy caveat to be aware of when using the `TRAP cleanup EXIT` pattern is that your script exit code may be changed by the commands in the cleanup function. Therefore, it can be handy to capture the exit code at the start of the cleanup function, and then apply it at the end, like so:
```bash
function cleanup() {
    exit_code="${?}"
    # some commands
    exit "${exit_code}"
}
trap cleanup SIGINT
trap cleanup EXIT
```
---
## Shellcheck
Bash scripting can be quite difficult because there are always multiple ways to cut your code, and no matter which way you choose to slice, you always run the risk of getting hurt. Thankfully there are ways to automatically check your code via static code analysis to keep your hands unscathed.

[Shellcheck](https://github.com/koalaman/shellcheck) is a great static code analysis tool to ensure you follow best practices and avoid silly mistakes. Shellcheck fits in very nicely in continuous integration pipelines since it is fast and can be run via docker (`docker run --rm -v "$PWD:/mnt" koalaman/shellcheck:stable myscript`). The output of shellcheck is also particularly useful since all rule violations include a link to a webpage explaining why this code is bad, and how to fix it. 

---
## Idempotency
This last point is a bit different from the others since it focuses on how we should write our Bash scripts (or indeed any script) from a philosophical perspective, rather than a technical one.

When we write scripts because we want to automate work which could be modifying the state of a machine or the state of a file. This changing of the state is known as side effects. For a script to be considered correct, it should produce the correct side effects when run. However, what we have overlooked in the scenario we have just outlined is what should happen if the script is run twice. Should the side effect be produced again, or should it not do any work since the effect has already been done? The answer is, if the script were written with idempotency in mind, then the script would not produce any more side effects after the original state was changed to the desired state. 

To define this more precisely by quoting Wikipedia:
> [Idempotence is the property of certain operations in mathematics and computer science whereby they can be applied multiple times without changing the result beyond the initial application.](https://en.wikipedia.org/wiki/Idempotence)

This characteristic is desirable since it makes it easier to reason with how our scripts should behave when run because the world is in either one of two states: before the script has been run, or after the scripts have been run. Furthermore, it also protects from potential harms created from running a script twice and producing the same effect twice (for example double-charging customers).

---
# Now get Bashing!
