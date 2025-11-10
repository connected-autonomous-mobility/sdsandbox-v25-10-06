# Troubleshooting: HTTP REST Server Port Error (38000-38100)

## Error Message
```
Error opening a HTTP REST server port between 38000 and 38100
```

## Overview
This error occurs when launching the SdSandbox Unity simulator on Linux systems. It indicates that Unity's embedded HTTP server cannot bind to any port in the 38000-38100 range. This is a Unity engine issue, not a problem with the simulator code itself.

## Root Causes

### 1. Missing SSL Libraries (Most Common)
Unity on Linux requires specific SSL libraries that are not included in newer Linux distributions by default. This is the most common cause of the error.

**Affected Systems:**
- Ubuntu 22.04 and later
- Debian 11 and later
- Other modern Linux distributions

**Solution:**
Install the required `libssl1.0.0` library:

```bash
# For Ubuntu/Debian-based systems

# Option 1: Download and install the package manually
wget http://security.ubuntu.com/ubuntu/pool/main/o/openssl1.0/libssl1.0.0_1.0.2n-1ubuntu5_amd64.deb
sudo dpkg -i libssl1.0.0_1.0.2n-1ubuntu5_amd64.deb
sudo apt-get -f install
```

```bash
# Option 2: For Ubuntu 20.04 (if the package is still available)
sudo apt-get update
sudo apt-get install libssl1.0.0
```

**Alternative for newer systems:**
If the above doesn't work, try installing compatibility libraries:

```bash
sudo apt-get install libssl-dev
```

### 2. Port Conflicts
Another process may already be using one or more ports in the 38000-38100 range.

**Diagnosis:**
Check which processes are using these ports:

```bash
# Check for processes using ports in the range
sudo netstat -tulpn | grep -E "380[0-9]{2}"

# Alternative using ss command
sudo ss -tulpn | grep -E "380[0-9]{2}"

# Alternative using lsof command
sudo lsof -i :38000-38100
```

**Solution:**
- If you find a conflicting process, stop it:
  ```bash
  sudo kill -9 <PID>
  ```
- Or, modify Unity to use a different port range (requires Unity source modifications)

### 3. Firewall Restrictions
Your firewall may be blocking the port range.

**Diagnosis:**
Check firewall status:

```bash
sudo ufw status
```

**Solution:**
Open the required port range:

```bash
# Allow TCP connections on ports 38000-38100
sudo ufw allow 38000:38100/tcp

# Reload firewall
sudo ufw reload
```

For other firewall systems (iptables):

```bash
sudo iptables -A INPUT -p tcp --dport 38000:38100 -j ACCEPT
sudo iptables-save > /etc/iptables/rules.v4
```

### 4. Unity Version Compatibility
Unity 2020.x versions have known issues with the HTTP REST server on Linux.

**Current Version:**
This project uses Unity 2020.3.49f1, which may exhibit this issue.

**Solution:**
Consider upgrading to Unity 2022 LTS or later:

1. Install Unity Hub
2. Install Unity 2022.3 LTS or later
3. Open the project with the new Unity version
4. Allow Unity to upgrade the project

**Note:** Project upgrades may introduce compatibility issues. Test thoroughly after upgrading.

## Quick Fix Checklist

Try these steps in order:

1. **Install SSL Libraries** (Most likely fix)
   ```bash
   wget http://security.ubuntu.com/ubuntu/pool/main/o/openssl1.0/libssl1.0.0_1.0.2n-1ubuntu5_amd64.deb
   sudo dpkg -i libssl1.0.0_1.0.2n-1ubuntu5_amd64.deb
   ```

2. **Check for Port Conflicts**
   ```bash
   sudo netstat -tulpn | grep -E "380[0-9]{2}"
   ```

3. **Open Firewall Ports**
   ```bash
   sudo ufw allow 38000:38100/tcp
   ```

4. **Restart Unity**
   - Close Unity completely
   - Restart the Unity Editor
   - Try launching the simulator again

5. **Verify Network Configuration**
   - Ensure localhost (127.0.0.1) is accessible
   - Check that no network-level restrictions exist

## Verification

After applying fixes, verify the solution:

1. Start Unity and open the SdSandbox project
2. Load a scene (e.g., `Assets/Scenes/road_generator`)
3. Click Play to start the simulator
4. Check the Unity Console for any error messages
5. Try connecting a Python client to verify network connectivity

## Additional Resources

- [Unity Linux Release Notes](https://forum.unity3d.com/threads/unity-on-linux-release-notes-and-known-issues.350256/)
- [Unity HTTP Server Documentation](https://docs.unity3d.com/)
- [SdSandbox Main README](../../README.md)

## Still Having Issues?

If you've tried all the above solutions and still encounter the error:

1. Check your system logs:
   ```bash
   journalctl -xe | grep -i "unity\|port\|ssl"
   ```

2. Verify your system information:
   ```bash
   lsb_release -a
   uname -a
   ```

3. Check Unity version:
   - In Unity, go to Help → About Unity

4. Create an issue on GitHub with:
   - Your operating system and version
   - Unity version
   - Error messages from Unity Console
   - Output from the diagnostic commands above
   - Steps you've already tried

## Prevention

To avoid this issue on new installations:

1. Install SSL libraries before installing Unity:
   ```bash
   # Add the libssl1.0.0 library during initial setup
   wget http://security.ubuntu.com/ubuntu/pool/main/o/openssl1.0/libssl1.0.0_1.0.2n-1ubuntu5_amd64.deb
   sudo dpkg -i libssl1.0.0_1.0.2n-1ubuntu5_amd64.deb
   ```

2. Use a supported Linux distribution
   - Ubuntu 20.04 LTS or later
   - Ensure all system updates are applied

3. Consider using Docker for consistent environment
   - Isolates dependencies
   - Ensures reproducible builds
