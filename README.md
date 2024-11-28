# Falcoctl Demo 🦅

This is a demo of [falcoctl](https://falco.org/blog/falcoctl-install-manage-rules-plugins/), a tool to help manage Falco artifacts.

## Run the Demo Script 🚀

In this demo script, we will do the following, all in a single Linux virtual machine that has Falco already installed:

>NOTE: This assumes running on a linux machine. Falco itself isn't used in the demo, rather Falcoctl, but of course you would want to use Falco to actually see the rules in action.

1. Install falcoctl from GitHub releases
2. Set up the falcoctl index and configuration
3. Create a systemd service for falcoctl
4. Create and push custom Falco rules to an OCI registry
5. Configure falcoctl to follow those rules by editing the falcoctl config file
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

## Adding an Index with falcoctl

See the [docs](https://github.com/falcosecurity/falcoctl?tab=readme-ov-file#falcoctl-artifact) for more information on artifacts.

An index is a collection of artifacts. Here we add an index as a file from the file system.

This is the example index.yaml file. It has a single artifact in it, a rulesfile that is located in quay.io/c_collicutt/falco-rules.

```yaml
- name: curtis-demo-rules
  type: rulesfile
  registry: quay.io
  repository: c_collicutt/falco-rules
  description: Curtis Demo Rules
  home: https://github.com/ccollicutt/falcoctl-demo/
  keywords:
    - curtis
    - demo
  license: Apache-2.0
  maintainers:
    - email: curtis@serverascode.com
      name: Curtis Collicutt
  sources:
    - https://github.com/ccollicutt/falcoctl-demo/
```

Add the index.

```bash
# falcoctl index add curtis-demo file:///root/curtis-index.yaml
2024-11-28 15:36:50 INFO  Adding index name: curtis-demo path: file:///root/curtis-index.yaml
2024-11-28 15:36:50 INFO  Index successfully added 
```

Now search based on keywords.

```bash
# alias fa="falcoctl artifact"
# fa search curtis
INDEX      	ARTIFACT         	TYPE     	REGISTRY	REPOSITORY
curtis-demo	curtis-demo-rules	rulesfile	quay.io 	c_collicutt/falco-rules
```

Get more information about the artifact. Note that falcoctl knows about the versions of the artifact based on the tags automatically.

```bash
# fa info curtis-demo-rules
REF                            	TAGS
quay.io/c_collicutt/falco-rules	1, 1.0.0, 1.0.1, 1.0.2, 1.0.3, 1.0.4, 1.0.5, 1.0.6, 1.0.7, latest
```

We can tell falcoctl to follow the artifact. By default it will follow the latest version.

```bash
# fa follow curtis-demo-rules
```

## Further Reading

* [https://falco.org/blog/gitops-your-falco-rules/](https://falco.org/blog/gitops-your-falco-rules/)
* [https://falco.org/blog/falcoctl-install-manage-rules-plugins/](https://falco.org/blog/falcoctl-install-manage-rules-plugins/)
* [https://falco.org/docs/falcoctl/](https://falco.org/docs/falcoctl/)
* [https://falco.org/blog/gitlab-supports-falcoctl-ociartifacts/](https://falco.org/blog/gitlab-supports-falcoctl-ociartifacts/)
