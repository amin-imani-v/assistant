################################################
#                                              #
#                                              #
#     This script written by [AMIN IMANI]      #
#                    2022                      #
#                                              #
#                                              #
################################################

#ENV

echo "****** secure sshd daemon ******"
sed -i 's/#Port 22/Port 5200/g' /etc/ssh/sshd_config  #change sshd port
sed -i 's/PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config  # disable root to login with ssh
sed -i 's/X11Forwarding yes/X11Forwarding no/g' /etc/ssh/sshd_config  #disable x11 forwarding for disabling forward graphical apps

# Set timeout for idle ssh session
touch /etc/profile.d/autologout.sh  #Create security profile for ssh
echo TMOUT=300 > /etc/profile.d/autologout.sh #set idle session timeout
echo readonly TMOUT >> /etc/profile.d/autologout.sh #protect TMOUT variable
echo export TMOUT >> /etc/profile.d/autologout.sh #export TMOUT variable for global usage

# Enable warning banner
touch /etc/ssh/sshd-banner  #Create a file for ssh banner. this message used when you ssh to a server.
echo "****** Warning! Authorized users only *****" > /etc/ssh/sshd-banner #copy message to file. for change message you should change this line
sed -i 's/#Banner none/Banner \/etc\/ssh\/sshd-banner/g' /etc/ssh/sshd_config #set banner config in sshd config file

# Disabling SSH tunneling
echo AllowTcpForwarding no >> /etc/ssh/sshd_config  #this line used to protect sshd service to forward traffic
echo AllowStreamLocalForwarding no >> /etc/ssh/sshd_config
echo GatewayPorts no >> /etc/ssh/sshd_config
echo PermitTunnel no >> /etc/ssh/sshd_config

systemctl restart sshd