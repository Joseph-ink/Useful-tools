#include <linux/bpf.h>
#include <linux/if_ether.h>
#include <linux/ip.h>
#include <linux/ipv6.h>
#include <netinet/in.h>
#include <linux/udp.h>
#include <linux/tcp.h>
#include <bpf/bpf_helpers.h>

#define TARGET_IPV4 0x04030201 // 1.2.3.4 (目标IPv4地址，使用网络字节序)
#define TARGET_PORT 12345 // 目标端口
static const __u8 target_ipv6[] = { 0x20, 0x01, 0x0d, 0xb8, 0x85, 0xa3, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01 }; // 目标IPv6地址

SEC("prog")
int xdp_forward(struct xdp_md *ctx) {
  void *data_end = (void *)(long)ctx->data_end;
  void *data = (void *)(long)ctx->data;

  struct ethhdr *eth = data;
  if ((void *)(eth + 1) > data_end) {
    return XDP_PASS;
  }

  if (eth->h_proto == htons(ETH_P_IP)) {
    struct iphdr *iph = (struct iphdr *)(eth + 1);
    if ((void *)(iph + 1) > data_end) {
      return XDP_PASS;
    }

    iph->daddr = TARGET_IPV4;

    if (iph->protocol == IPPROTO_UDP) {
      struct udphdr *udph = (struct udphdr *)(iph + 1);
      if ((void *)(udph + 1) > data_end) {
        return XDP_PASS;
      }
      udph->dest = htons(TARGET_PORT);
    } else if (iph->protocol == IPPROTO_TCP) {
      struct tcphdr *tcph = (struct tcphdr *)(iph + 1);
      if ((void *)(tcph + 1) > data_end) {
        return XDP_PASS;
      }
      tcph->dest = htons(TARGET_PORT);
    } else {
      return XDP_PASS;
    }
  } else if (eth->h_proto == htons(ETH_P_IPV6)) {
    struct ipv6hdr *ip6h = (struct ipv6hdr *)(eth + 1);
    if ((void *)(ip6h + 1) > data_end) {
      return XDP_PASS;
    }

    memcpy(ip6h->daddr.s6_addr, target_ipv6, sizeof(target_ipv6));

    if (ip6h->nexthdr == IPPROTO_UDP) {
      struct udphdr *udph = (struct udphdr *)(ip6h + 1);
    if ((void *)(udph + 1) > data_end) {
      return XDP_PASS;
    }
    udph->dest = htons(TARGET_PORT);
  } else if (ip6h->nexthdr == IPPROTO_TCP) {
      struct tcphdr *tcph = (struct tcphdr *)(ip6h + 1);
      if ((void *)(tcph + 1) > data_end) {
        return XDP_PASS;
      }
      tcph->dest = htons(TARGET_PORT);
    } else {
      return XDP_PASS;
    }
  } else {
    return XDP_PASS;
  }

  return XDP_TX;
}

char _license[] SEC("license") = "GPL";
