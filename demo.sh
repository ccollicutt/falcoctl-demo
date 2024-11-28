#!/bin/bash
set -e

RULES_PATH="./custom_rules.yaml"

######################
# Initial Setup
######################

# Check required environment variables
echo "Checking required environment variables..."
required_vars=("OCI_ARTIFACT_VERSION" "OCI_REGISTRY" "OCI_REPOSITORY" "OCI_USERNAME" "OCI_PASSWORD" "RULESET_FILE")
for var in "${required_vars[@]}"; do
    if [ -z "${!var}" ]; then
        echo "Error: $var is not set"
        exit 1
    fi
done

######################
# Falcoctl Installation
######################

echo "Installing falcoctl..."

# Install falcoctl from GitHub releases
LATEST=$(curl -sI https://github.com/falcosecurity/falcoctl/releases/latest | awk '/location: /{gsub("\r","",$2);split($2,v,"/");print substr(v[8],2)}')
curl --fail -LS "https://github.com/falcosecurity/falcoctl/releases/download/v${LATEST}/falcoctl_${LATEST}_linux_amd64.tar.gz" | tar -xz
sudo install -o root -g root -m 0755 falcoctl /usr/local/bin/falcoctl

read -p "Press Enter to continue with falcoctl index setup..."

######################
# Falcoctl Index Setup
######################

echo "Setting up falcoctl index..."
# Add the falcosecurity index
sudo rm /etc/falcoctl/falcoctl.yaml
sudo falcoctl index add falcosecurity https://falcosecurity.github.io/falcoctl/index.yaml

read -p "Press enter to see the falcoctl artifact list..."

falcoctl artifact list

echo "Press enter to see the falcoctl configuration..."
read -p ""

echo "=============================================="
cat /etc/falcoctl/falcoctl.yaml
echo "=============================================="
read -p "Press Enter to continue with systemd service setup..."

######################
# Systemd Service Setup
######################

echo "Creating systemd service..."
# Create systemd service for falcoctl
cat << 'EOF' | sudo tee /etc/systemd/system/falcoctl.service
[Unit]
Description=Falcoctl
After=network.target
StartLimitIntervalSec=0

[Service]
Type=simple
Restart=always
RestartSec=1
ExecStart=/usr/local/bin/falcoctl artifact follow

[Install]
WantedBy=multi-user.target
EOF

# Enable and start the service
sudo systemctl enable falcoctl
sudo systemctl start falcoctl

read -p "Press enter to login to a registry with falcoctl... "

falcoctl registry auth basic ${OCI_REGISTRY} -u ${OCI_USERNAME} -p ${OCI_PASSWORD}

read -p "Press enter to continue with custom rules creation... "
######################
# Custom Rules Creation
######################

echo "Creating custom rules..."

# Create custom rules with version
rm ${RULES_PATH}
cat << EOF > ${RULES_PATH}
---
# version: ${OCI_ARTIFACT_VERSION}
- list: falco_binaries
  items: [falcoctl]
EOF

echo "Current rules version:"
grep "^# version:" /etc/falco/custom_rules.yaml

read -p "Press Enter to continue with registry operations..."

######################
# Registry Operations
######################

echo "Pushing custom rules to registry..."
falcoctl registry push \
    --config /dev/null \
    --type rulesfile \
    --version ${OCI_ARTIFACT_VERSION} \
    ${OCI_REGISTRY}/${OCI_REPOSITORY}:${OCI_ARTIFACT_VERSION} \
    ${RULES_PATH}

read -p "Press enter to verify pushed version..."

echo "Verifying pushed version..."
falcoctl registry pull \
    --config /dev/null \
    ${OCI_REGISTRY}/${OCI_REPOSITORY}:${OCI_ARTIFACT_VERSION}

# also tag as latest
falcoctl registry tag \
    --config /dev/null \
    ${OCI_REGISTRY}/${OCI_REPOSITORY}:${OCI_ARTIFACT_VERSION} \
    ${OCI_REGISTRY}/${OCI_REPOSITORY}:latest

echo "Pulled version:"
grep "^# version:" ${RULES_PATH}

######################
# Falcoctl Configuration
######################

echo "Press enter to update the falcoctl configuration..."

cat << EOF > /etc/falcoctl/falcoctl.yaml
artifact:
    follow:
        every: 0h5m0s
        falcoversions: http://localhost:8765/versions
        refs:
            - falco-rules:3
            - quay.io/c_collicutt/falco-rules:${OCI_ARTIFACT_VERSION}
driver:
    hostroot: /
    name: falco
    repos:
        - https://download.falco.org/driver
    type:
        - modern_ebpf
    version: 7.3.0+driver
indexes:
    - name: falcosecurity
      url: https://falcosecurity.github.io/falcoctl/index.yaml
      backend: ""
EOF

echo "=============================================="
cat /etc/falcoctl/falcoctl.yaml
echo "=============================================="

rm /etc/falco/custom_rules.yaml || true

read -p "Press enter to restart falcoctl service..."

sudo systemctl restart falcoctl && sudo systemctl status falcoctl

echo "Sleeping for 10 seconds to allow falco to pick up the new rules..."
sleep 10

read -p "Press enter to see the new falco rules file... "

echo "=============================================="
echo "catting /etc/falco/custom_rules.yaml"
cat /etc/falco/custom_rules.yaml
echo "=============================================="

echo "Demo script complete!"
