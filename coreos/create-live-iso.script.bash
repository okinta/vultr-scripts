#!/usr/bin/env bash

#
# Creates an ISO that will automatically call coreos/install.bash upon booting
#

# ARG_OPTIONAL_SINGLE([logdna-ingestion-key],[],[The LogDNA Ingestion Key to use to forward logs])
# ARG_OPTIONAL_BOOLEAN([second-phase],[],[Whether or not this is the second phase for this script])
# ARG_POSITIONAL_SINGLE([vultr-api-key],[The Vultr API key to use for communicating with Vultr],[])
# ARG_POSITIONAL_SINGLE([cloudflare-email],[The email to use for updating Cloudflare DNS],[])
# ARG_POSITIONAL_SINGLE([cloudflare-api-key],[The API key to use for updating Cloudflare DNS],[])
# ARG_POSITIONAL_SINGLE([cloudflare-zonename],[The Cloudflare zone to host the ISO],[])
# ARG_POSITIONAL_SINGLE([cloudflare-recordname],[The Cloudflare record name to host the ISO],[])
# ARG_DEFAULTS_POS()
# ARG_HELP([Builds an ISO that can be used to install Fedora CoreOS])
# ARGBASH_GO()
# needed because of Argbash --> m4_ignore([
### START OF CODE GENERATED BY Argbash v2.8.1 one line above ###
# Argbash is a bash code generator used to get arguments parsing right.
# Argbash is FREE SOFTWARE, see https://argbash.io for more info
# Generated online by https://argbash.io/generate


die()
{
    local _ret=$2
    test -n "$_ret" || _ret=1
    test "$_PRINT_HELP" = yes && print_help >&2
    echo "$1" >&2
    exit ${_ret}
}


begins_with_short_option()
{
    local first_option all_short_options='h'
    first_option="${1:0:1}"
    test "$all_short_options" = "${all_short_options/$first_option/}" && return 1 || return 0
}

# THE DEFAULTS INITIALIZATION - POSITIONALS
_positionals=()
_arg_vultr_api_key=
_arg_cloudflare_email=
_arg_cloudflare_api_key=
_arg_cloudflare_zonename=
_arg_cloudflare_recordname=
# THE DEFAULTS INITIALIZATION - OPTIONALS
_arg_logdna_ingestion_key=
_arg_second_phase="off"


print_help()
{
    printf '%s\n' "Builds an ISO that can be used to install Fedora CoreOS"
    printf 'Usage: %s [--logdna-ingestion-key <arg>] [--(no-)second-phase] [-h|--help] <vultr-api-key> <cloudflare-email> <cloudflare-api-key> <cloudflare-zonename> <cloudflare-recordname>\n' "$0"
    printf '\t%s\n' "<vultr-api-key>: The Vultr API key to use for communicating with Vultr"
    printf '\t%s\n' "<cloudflare-email>: The email to use for updating Cloudflare DNS"
    printf '\t%s\n' "<cloudflare-api-key>: The API key to use for updating Cloudflare DNS"
    printf '\t%s\n' "<cloudflare-zonename>: The Cloudflare zone to host the ISO"
    printf '\t%s\n' "<cloudflare-recordname>: The Cloudflare record name to host the ISO"
    printf '\t%s\n' "--logdna-ingestion-key: The LogDNA Ingestion Key to use to forward logs (no default)"
    printf '\t%s\n' "--second-phase, --no-second-phase: Whether or not this is the second phase for this script (off by default)"
    printf '\t%s\n' "-h, --help: Prints help"
}


parse_commandline()
{
    _positionals_count=0
    while test $# -gt 0
    do
        _key="$1"
        case "$_key" in
            --logdna-ingestion-key)
                test $# -lt 2 && die "Missing value for the optional argument '$_key'." 1
                _arg_logdna_ingestion_key="$2"
                shift
                ;;
            --logdna-ingestion-key=*)
                _arg_logdna_ingestion_key="${_key##--logdna-ingestion-key=}"
                ;;
            --no-second-phase|--second-phase)
                _arg_second_phase="on"
                test "${1:0:5}" = "--no-" && _arg_second_phase="off"
                ;;
            -h|--help)
                print_help
                exit 0
                ;;
            -h*)
                print_help
                exit 0
                ;;
            *)
                _last_positional="$1"
                _positionals+=("$_last_positional")
                _positionals_count=$((_positionals_count + 1))
                ;;
        esac
        shift
    done
}


handle_passed_args_count()
{
    local _required_args_string="'vultr-api-key', 'cloudflare-email', 'cloudflare-api-key', 'cloudflare-zonename' and 'cloudflare-recordname'"
    test "${_positionals_count}" -ge 5 || _PRINT_HELP=yes die "FATAL ERROR: Not enough positional arguments - we require exactly 5 (namely: $_required_args_string), but got only ${_positionals_count}." 1
    test "${_positionals_count}" -le 5 || _PRINT_HELP=yes die "FATAL ERROR: There were spurious positional arguments --- we expect exactly 5 (namely: $_required_args_string), but got ${_positionals_count} (the last one was: '${_last_positional}')." 1
}


assign_positional_args()
{
    local _positional_name _shift_for=$1
    _positional_names="_arg_vultr_api_key _arg_cloudflare_email _arg_cloudflare_api_key _arg_cloudflare_zonename _arg_cloudflare_recordname "

    shift "$_shift_for"
    for _positional_name in ${_positional_names}
    do
        test $# -gt 0 || break
        eval "$_positional_name=\${1}" || die "Error during argument parsing, possibly an Argbash bug." 1
        shift
    done
}

parse_commandline "$@"
handle_passed_args_count
assign_positional_args 1 "${_positionals[@]}"

# OTHER STUFF GENERATED BY Argbash

### END OF CODE GENERATED BY Argbash (sortof) ### ])
# [ <-- needed because of Argbash
# ] <-- needed because of Argbash

export VULTR_API_KEY="$_arg_vultr_api_key"

function forward_logs {
    if [ -z "$_arg_logdna_ingestion_key" ]; then
        echo "LogDNA Ingestion Key not provided"
        return
    fi

    echo "deb https://repo.logdna.com stable main" | tee /etc/apt/sources.list.d/logdna.list
    wget -O- https://repo.logdna.com/logdna.gpg | apt-key add -
    apt update
    apt install -y logdna-agent
    logdna-agent -k "$_arg_logdna_ingestion_key"
    logdna-agent -d /tmp
    logdna-agent -d /var/log
    logdna-agent -t buildiso
    update-rc.d logdna-agent defaults
    /etc/init.d/logdna-agent start
}

function upgrade {
    apt update
    apt upgrade -y
    apt autoremove -y
}

function setup_second_boot {
    # On boot, run this script again
    # shellcheck disable=SC2016
    {
        echo '#!/usr/bin/env bash';
        echo "VULTR_API_KEY=$VULTR_API_KEY";
        echo "LOGDNA_INGESTION_KEY=$LOGDNA_INGESTION_KEY";
        echo 'bash -c "$(curl -fsSL https://raw.githubusercontent.com/okinta/vultr-scripts/master/coreos/create-live-iso.script.bash)" "" "$VULTR_API_KEY" "$LOGDNA_INGESTION_KEY" "--second-boot" > /var/log/secondboot.log 2>&1';
    } > /etc/rc.local
    chmod +x /etc/rc.local
}

function install_tools {
    apt update
    apt install -y \
        gettext-base \
        jq \
        unzip

    # coreos-installer
    wget -q -O /usr/local/bin/coreos-installer https://s3.okinta.ge/coreos-installer-ubuntu-0.1.3
    chmod +x /usr/local/bin/coreos-installer

    # fcct
    wget -q -O /usr/local/bin/fcct https://s3.okinta.ge/fcct-x86_64-unknown-linux-gnu-0.5.0
    chmod +x /usr/local/bin/fcct

    # yq
    wget -q -O /usr/local/bin/yq https://s3.okinta.ge/yq_linux_amd64_3.3.0
    chmod +x /usr/local/bin/yq

    # vultr-cli
    echo "export VULTR_API_KEY=$VULTR_API_KEY" >> /root/.bashrc
    wget -q -O vultr-cli.tar.gz https://s3.okinta.ge/vultr-cli_0.3.0_linux_64-bit.tar.gz
    tar -xzf vultr-cli.tar.gz -C /usr/local/bin
    chmod +x /usr/local/bin/vultr-cli
    rm -f vultr-cli.tar.gz
}

function setup_coreos {
    # On boot, run install-coreos.bash
    # shellcheck disable=SC2016
    echo '#!/usr/bin/env bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/okinta/vultr-scripts/master/coreos/install.bash)" > /var/log/install.log 2>&1' > /etc/rc.local
    chmod +x /etc/rc.local
}

function build_iso {
    # Build the ISO
    apt install -y mkisofs
    wget -q -O linux-live.zip https://s3.okinta.ge/linux-live-2.3.zip
    unzip -q -d /tmp linux-live.zip
    rm -f linux-live.zip

    # Remove second boot option so we can boot immediately instead of waiting
    head -13 /tmp/linux-live-2.3/bootfiles/syslinux.cfg > syslinux.cfg
    mv syslinux.cfg /tmp/linux-live-2.3/bootfiles/syslinux.cfg

    /tmp/linux-live-2.3/build
    /tmp/gen_linux_iso.sh
}

function upload_iso {
    local external_ip
    external_ip=$(ifconfig ens3 | grep "inet " | awk '{print $2}')

    # Update the DNS to point to this server
    wget -q -O cf-ddns.sh.zip \
        https://s3.okinta.ge/cf-ddns.sh-3892d9c6607b497331b2cd7ad1f5889131e6d135.zip
    unzip -q -d /tmp cf-ddns.sh.zip
    mv /tmp/cf-ddns.sh-3892d9c6607b497331b2cd7ad1f5889131e6d135/cf-ddns.sh /usr/local/bin
    chmod +x /usr/local/bin/cf-ddns.sh
    rm -rf /tmp/cf-ddns.sh-* cf-ddns.sh.zip
    cf-ddns.sh \
        --email="$_arg_cloudflare_email" \
        --apikey="$_arg_cloudflare_api_key" \
        --zonename="$_arg_cloudflare_zonename" \
        --recordname="$_arg_cloudflare_recordname" \
        -wan="$external_ip"

    # Host the ISO file so Vultr can download it
    apt install -y nginx
    ufw allow "Nginx HTTPS"
    local password
    password=$(openssl rand 9999 | sha256sum | awk '{print $1}')
    mkdir "/var/www/html/$password"
    mv /tmp/linux-x86_64.iso "/var/www/html/$password/installcoreos.iso"

    # Delete the old ISO if it exists
    local image_id
    image_id=$(vultr-cli iso private | grep installcoreos | awk '{print $1}')
    if ! [ -z "$image_id" ]; then
        vultr-cli iso delete "$image_id"
    fi

    # Tell Vultr to download the ISO
    local url="$_arg_cloudflare_recordname.$_arg_cloudflare_zonename"
    vultr-cli iso create --url "https://$url/$password/installcoreos.iso"
    echo "Started upload"

    # Wait until the image has finished uploading
    sleep 60
    image_id=$(vultr-cli iso private | grep installcoreos | awk '{print $1}')
    while [ -z "$image_id" ]; do
        image_id=$(vultr-cli iso private | grep installcoreos | awk '{print $1}')
        sleep 60
    done

    rm -rf "/var/www/html/$password"
}

function destroy_self {
    # Destroy self since our existence no longer serves any purpose
    local id
    id="$(curl -s http://169.254.169.254/v1.json | jq ".instanceid" | tr -d '"')"
    vultr-cli server delete "$id"
}

if [ $_arg_second_phase = off ]; then
    forward_logs
    upgrade
    setup_second_boot
    reboot

else
    install_tools
    setup_coreos
    build_iso
    upload_iso
    destroy_self
fi
