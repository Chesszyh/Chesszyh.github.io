#!/bin/bash

# VPS Network Performance Test Script
# Comprehensive network testing for VPS performance evaluation

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
VPS_IP="178.128.217.160"
LOG_FILE="network_test_$(date +%Y%m%d_%H%M%S).log"
REPORT_FILE="network_report_$(date +%Y%m%d_%H%M%S).txt"

# Test targets
PING_TARGETS=(
    "8.8.8.8"
    "1.1.1.1"
    "223.5.5.5"
    "114.114.114.114"
    "google.com"
    "baidu.com"
    "github.com"
)

TRACEROUTE_TARGETS=(
    "8.8.8.8"
    "google.com"
    "baidu.com"
)

SPEEDTEST_SERVERS=(
    "https://speed.cloudflare.com/__down?bytes=104857600"  # 100MB
    "http://speedtest.tele2.net/100MB.zip"
    "https://ash-speed.hetzner.com/100MB.bin"
)

# Utility functions
print_header() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
}

print_section() {
    echo -e "\n${GREEN}--- $1 ---${NC}"
}

print_warning() {
    echo -e "${YELLOW}Warning: $1${NC}"
}

print_error() {
    echo -e "${RED}Error: $1${NC}"
}

log_output() {
    echo "$1" | tee -a "$LOG_FILE"
}

# Check if required tools are installed
check_dependencies() {
    print_section "Checking Dependencies"
    
    local deps=("ping" "traceroute" "curl" "wget" "iperf3" "nmap" "ss" "netstat")
    local missing_deps=()
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing_deps+=("$dep")
        else
            echo "✓ $dep found"
        fi
    done
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        print_warning "Missing dependencies: ${missing_deps[*]}"
        echo "Installing missing packages..."
        
        if command -v apt-get &> /dev/null; then
            sudo apt-get update
            sudo apt-get install -y traceroute curl wget iperf3 nmap net-tools
        elif command -v yum &> /dev/null; then
            sudo yum install -y traceroute curl wget iperf3 nmap net-tools
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y traceroute curl wget iperf3 nmap net-tools
        else
            print_error "Package manager not found. Please install missing dependencies manually."
            exit 1
        fi
    fi
}

# Basic system information
get_system_info() {
    print_section "System Information"
    
    log_output "Hostname: $(hostname)"
    log_output "OS: $(cat /etc/os-release | grep PRETTY_NAME | cut -d= -f2 | tr -d '\"')"
    log_output "Kernel: $(uname -r)"
    log_output "Architecture: $(uname -m)"
    log_output "CPU Cores: $(nproc)"
    log_output "Memory: $(free -h | awk '/^Mem:/ {print $2}')"
    log_output "Uptime: $(uptime -p)"
    log_output "Current Time: $(date)"
    log_output "VPS IP: $VPS_IP"
}

# Network interface information
get_network_info() {
    print_section "Network Interface Information"
    
    log_output "Network Interfaces:"
    ip addr show | tee -a "$LOG_FILE"
    
    echo "" | tee -a "$LOG_FILE"
    log_output "Routing Table:"
    ip route show | tee -a "$LOG_FILE"
    
    echo "" | tee -a "$LOG_FILE"
    log_output "DNS Configuration:"
    cat /etc/resolv.conf | tee -a "$LOG_FILE"
}

# Ping tests for latency and packet loss
ping_tests() {
    print_section "Ping Tests (Latency & Packet Loss)"
    
    for target in "${PING_TARGETS[@]}"; do
        echo "Testing ping to $target..." | tee -a "$LOG_FILE"
        ping -c 10 -i 0.2 "$target" 2>&1 | tee -a "$LOG_FILE" || print_warning "Ping to $target failed"
        echo "" | tee -a "$LOG_FILE"
    done
}

# MTU discovery
mtu_discovery() {
    print_section "MTU Discovery"
    
    for target in "8.8.8.8" "google.com"; do
        echo "MTU discovery to $target:" | tee -a "$LOG_FILE"
        
        # Try different packet sizes to find MTU
        for size in 1500 1472 1400 1200 1000; do
            if ping -c 1 -M do -s $size "$target" &>/dev/null; then
                log_output "MTU to $target: $((size + 28)) bytes (payload: $size bytes)"
                break
            fi
        done
    done
}

# Traceroute tests
traceroute_tests() {
    print_section "Traceroute Tests"
    
    for target in "${TRACEROUTE_TARGETS[@]}"; do
        echo "Traceroute to $target:" | tee -a "$LOG_FILE"
        traceroute "$target" 2>&1 | tee -a "$LOG_FILE" || print_warning "Traceroute to $target failed"
        echo "" | tee -a "$LOG_FILE"
    done
}

# DNS resolution speed tests
dns_tests() {
    print_section "DNS Resolution Tests"
    
    local domains=("google.com" "baidu.com" "github.com" "stackoverflow.com" "reddit.com")
    local dns_servers=("8.8.8.8" "1.1.1.1" "223.5.5.5")
    
    for dns in "${dns_servers[@]}"; do
        echo "Testing DNS server: $dns" | tee -a "$LOG_FILE"
        for domain in "${domains[@]}"; do
            result=$(dig @"$dns" "$domain" +short +time=2 +tries=1 2>&1)
            if [ $? -eq 0 ]; then
                echo "  $domain -> $result" | tee -a "$LOG_FILE"
            else
                echo "  $domain -> FAILED" | tee -a "$LOG_FILE"
            fi
        done
        echo "" | tee -a "$LOG_FILE"
    done
}

# Port connectivity tests
port_tests() {
    print_section "Port Connectivity Tests"
    
    local test_ports=(
        "google.com:80"
        "google.com:443"
        "github.com:22"
        "github.com:443"
        "baidu.com:80"
        "8.8.8.8:53"
    )
    
    for target in "${test_ports[@]}"; do
        host=$(echo "$target" | cut -d: -f1)
        port=$(echo "$target" | cut -d: -f2)
        
        echo "Testing connection to $host:$port..." | tee -a "$LOG_FILE"
        if timeout 5 nc -z "$host" "$port" 2>/dev/null; then
            echo "  ✓ Connection successful" | tee -a "$LOG_FILE"
        else
            echo "  ✗ Connection failed" | tee -a "$LOG_FILE"
        fi
    done
}

# Bandwidth tests
bandwidth_tests() {
    print_section "Bandwidth Tests"
    
    echo "Download Speed Tests:" | tee -a "$LOG_FILE"
    
    for url in "${SPEEDTEST_SERVERS[@]}"; do
        echo "Testing download from: $url" | tee -a "$LOG_FILE"
        
        start_time=$(date +%s.%N)
        curl -o /dev/null -s --max-time 30 "$url" 2>&1
        end_time=$(date +%s.%N)
        
        if [ $? -eq 0 ]; then
            duration=$(echo "$end_time - $start_time" | bc 2>/dev/null || echo "unknown")
            if [ "$duration" != "unknown" ]; then
                speed=$(echo "scale=2; 100 / $duration" | bc 2>/dev/null || echo "unknown")
                echo "  Download completed in ${duration}s, Speed: ${speed} MB/s" | tee -a "$LOG_FILE"
            else
                echo "  Download completed (duration calculation failed)" | tee -a "$LOG_FILE"
            fi
        else
            echo "  Download failed" | tee -a "$LOG_FILE"
        fi
    done
    
    echo "" | tee -a "$LOG_FILE"
    echo "Using curl for speed measurement:" | tee -a "$LOG_FILE"
    curl -o /dev/null -w "Download Speed: %{speed_download} bytes/sec\nTotal Time: %{time_total}s\n" -s "http://speedtest.tele2.net/10MB.zip" 2>&1 | tee -a "$LOG_FILE"
}

# iperf3 tests (if available)
iperf_tests() {
    print_section "iperf3 Tests"
    
    local iperf_servers=(
        "iperf.he.net"
        "speedtest.serverius.net"
        "ping.online.net"
    )
    
    for server in "${iperf_servers[@]}"; do
        echo "Testing iperf3 with $server:" | tee -a "$LOG_FILE"
        timeout 15 iperf3 -c "$server" -t 10 2>&1 | tee -a "$LOG_FILE" || echo "iperf3 test failed for $server" | tee -a "$LOG_FILE"
        echo "" | tee -a "$LOG_FILE"
    done
}

# Network stability test
stability_test() {
    print_section "Network Stability Test"
    
    echo "Running ping stability test to 8.8.8.8..." | tee -a "$LOG_FILE"
    # User can adjust the duration of the test
    read -r -p "Enter duration of stability test in seconds (default 300, skip: <Enter>): " time

    if [ -z "$time" ]; then
        time=300    
    elif [ "$time" -eq 0 ]; then
        echo "Skipping stability test"
        return
    fi    

    ping -c "$time" -i 1 8.8.8.8 2>&1 | tee -a "$LOG_FILE"
    
    echo "" | tee -a "$LOG_FILE"
    echo "Running concurrent ping test to multiple targets..." | tee -a "$LOG_FILE"
    
    for target in "8.8.8.8" "1.1.1.1" "google.com"; do
        ping -c 60 -i 1 "$target" > "ping_${target}_$(date +%s).tmp" 2>&1 &
    done
    
    wait
    
    for file in ping_*.tmp; do
        if [ -f "$file" ]; then
            echo "Results for ${file}:" | tee -a "$LOG_FILE"
            tail -n 5 "$file" | tee -a "$LOG_FILE"
            rm -f "$file"
        fi
    done
}

# Network load test
network_load_test() {
    print_section "Network Load Test"
    
    echo "Testing network under load (multiple concurrent connections)..." | tee -a "$LOG_FILE"
    
    # Start multiple background downloads
    for i in {1..5}; do
        curl -o "/tmp/test_${i}.tmp" -s "http://speedtest.tele2.net/10MB.zip" &
    done
    
    # Monitor ping during load
    ping -c 30 -i 1 8.8.8.8 > ping_under_load.tmp 2>&1 &
    
    # Wait for all downloads to complete
    wait
    
    echo "Ping results under network load:" | tee -a "$LOG_FILE"
    cat ping_under_load.tmp | tee -a "$LOG_FILE"
    
    # Cleanup
    rm -f /tmp/test_*.tmp ping_under_load.tmp
}

# Generate summary report
generate_report() {
    print_section "Generating Summary Report"
    
    {
        echo "VPS Network Performance Test Report"
        echo "=================================="
        echo "Test Date: $(date)"
        echo "VPS IP: $VPS_IP"
        echo ""
        echo "Test Summary:"
        echo "- System Information: Collected"
        echo "- Network Interfaces: Analyzed"
        echo "- Ping Tests: Completed for ${#PING_TARGETS[@]} targets"
        echo "- Traceroute Tests: Completed for ${#TRACEROUTE_TARGETS[@]} targets"
        echo "- DNS Resolution: Tested"
        echo "- Port Connectivity: Tested"
        echo "- Bandwidth Tests: Completed"
        echo "- Network Stability: 5-minute test completed"
        echo "- Network Load Test: Completed"
        echo ""
        echo "Detailed results are available in: $LOG_FILE"
        echo ""
        echo "Key Recommendations:"
        echo "1. Review ping results for high latency or packet loss"
        echo "2. Check traceroute for routing issues"
        echo "3. Verify DNS resolution speeds"
        echo "4. Monitor bandwidth consistency"
        echo "5. Analyze stability test results for connection drops"
    } > "$REPORT_FILE"
    
    echo "Summary report generated: $REPORT_FILE"
    cat "$REPORT_FILE"
}

# Cleanup function
cleanup() {
    print_section "Cleanup"
    
    # Kill any remaining background processes
    jobs -p | xargs -r kill 2>/dev/null || true
    
    # Remove temporary files
    rm -f /tmp/test_*.tmp ping_*.tmp
    
    echo "Cleanup completed"
}

# Main execution
main() {
    print_header "VPS Network Performance Test Suite"
    echo "Starting comprehensive network performance test for VPS: $VPS_IP"
    echo "Log file: $LOG_FILE"
    echo ""
    
    # Set trap for cleanup on exit
    trap cleanup EXIT
    
    check_dependencies
    get_system_info
    get_network_info
    ping_tests
    mtu_discovery
    traceroute_tests
    dns_tests
    port_tests
    bandwidth_tests
    
    if command -v iperf3 &> /dev/null; then
        iperf_tests
    else
        echo "iperf3 not available, skipping iperf tests" | tee -a "$LOG_FILE"
    fi
    
    stability_test
    network_load_test
    generate_report
    
    print_header "Test Completed Successfully"
    echo "Results saved to: $LOG_FILE"
    echo "Summary report: $REPORT_FILE"
}

# Check if script is run with appropriate permissions
if [[ $EUID -ne 0 ]]; then
    print_warning "This script is not running as root. Some tests may require sudo privileges."
    echo "For complete testing, consider running: sudo $0"
    echo ""
fi

# Run main function
main "$@"