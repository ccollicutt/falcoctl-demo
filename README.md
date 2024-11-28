# Falcoctl Talk 🦅

This is a talk about falcoctl, a tool to help manage Falco artifacts.

## Run the Demo Script 🚀

In this demo script, we will do the following, all in a single Linux virtual machine that has Falco already installed:

>NOTE: This assumes running on a linux machine. Falco itself isn't used in the demo, rather Falcoctl, but of course you would want to use Falco to actually see the rules in action.

1. Install falcoctl from GitHub releases
2. Set up the falcoctl index and configuration
3. Create a systemd service for falcoctl
4. Create and push custom Falco rules to an OCI registry
5. Configure falcoctl to follow those rules
6. Verify the rules are pulled and installed correctly

Set the environment variables and run the script.

```bash
export OCI_ARTIFACT_VERSION=<version>
export OCI_REGISTRY=<registry>
export OCI_REPOSITORY=<repository>
export RULESET_FILE=<ruleset-file>
export OCI_USERNAME=<username>
export OCI_PASSWORD=<password>
```

Run the demo script. ▶️
```bash
./demo.sh
```

## Run the asciinema files 🎬

This demo has been recorded with asciinema. To play the asciinema files, run the following command:

```bash
asciinema play asciinema/falcoctl-demo-sh-1.cast
```

## Further Reading

* [https://falco.org/blog/gitops-your-falco-rules/](https://falco.org/blog/gitops-your-falco-rules/)
* [https://falco.org/blog/falcoctl-install-manage-rules-plugins/](https://falco.org/blog/falcoctl-install-manage-rules-plugins/)
* [https://falco.org/docs/falcoctl/](https://falco.org/docs/falcoctl/)
* [https://falco.org/blog/gitlab-supports-falcoctl-ociartifacts/](https://falco.org/blog/gitlab-supports-falcoctl-ociartifacts/)
