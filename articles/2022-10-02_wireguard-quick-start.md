---
title: 'リモートアクセスVPNを構築したいのでWireGuardを調べる'
emoji: '🐉'
type: 'tech' # tech: 技術記事 / idea: アイデア
topics: ['wireguard', '初心者']
published: true
---

## はじめに

自宅内のデスクトップに外部ネットワークから接続するために リモートアクセス VPN を構築したい。WireGuard が便利らしいので使ってみます。

:::message
インフラ・セキュリティ等に関して初学者です。
正確さより理解しやすさを優先していますが、誤りなどがありましたらご指摘お願いします。
:::

## WireGuard とは？

WireGuard の詳細な説明は[WireGuard 公式](https://www.wireguard.com/)や他の方の説明力を多分に頼ることにします。

WireGuard の特徴はこちらによくまとまった記事がありました。
https://zenn.dev/hiroe_orz17/articles/f8f35075dea4cf

セキュリティについてはこちらにわかりやすい動画解説があります。
https://youtu.be/grDEBt7oQho?list=TLGGLG3hlt_Af5EwMTEwMjAyMg

### QuickStart

2 分半ほどの動画ですので、まずそちらから見てみてください。

https://www.wireguard.com/quickstart/

#### ざっくり整理

画面左右の Peer A,B でやっていることは概ね同じみたいです。

Peer A に注目すると、

1. 秘密鍵（及び公開鍵）を作成

2. 「 WireGuard 用の Network Interface = `wg0` 」を作成する

3. `wg0` に VPN で利用する IP アドレス(`10.0.0.1/24`)を指定する

4. `wg0`の通信で、WireGuard が利用する秘密鍵を指定する

5. `wg0` を起動し、`wg0`に指定した IP アドレスが`10.0.0.1/24`、実際の通信に利用している IP アドレスが`192.168.1.1/24`であることを確認する

6. Peer B との通信を設定する

6 の時に通信相手となる Peer B の「公開鍵」と「相手の実際の IP アドレス」、「相手の VPN 上の IP アドレス」を紐付けていそう。

上記の設定後、ping が走る時のイメージはこんな感じでしょうか。

![](/images/wireguard-quickstart.jpg)

元々の ネットワーク(`192.168.1.0/24`)の代わりに、WireGuard より構築した ネットワーク(`10.0.0.0/24`)を利用して通信をしているように見えます。

## WireGuard の理解

WireGuard を利用することで、Peer A,B の属するネットワーク内に、独立したネットワークが作れるようです。

Quick Start では Peer A の設定に Peer B の実際の IP アドレスを、Peer B の設定に Peer A の実際の IP アドレスを指定していましたが、どうやら片方の方向、例えば Peer A -> Peer B さえわかっていれば、WireGuard はいい感じに Peer B -> Peer A も実現してくれるみたいです。
https://www.wireguard.com/#built-in-roaming

ただし NAT 等を利用している場合は特別な設定が必要とのこと。
https://www.wireguard.com/quickstart/#nat-and-firewall-traversal-persistence

まとめると、WireGuard とは
**Peer A -> Peer B の接続が可能なとき、Peer A <-> Peer B の通信が可能なネットワークを構築できるツール**
と解釈してもよさそうです。

## リモートアクセス VPN

WireGuard を利用すれば Peer A -> Peer B を Peer A <-> Peer B にすることができます。

今回リモートアクセスしたい機器は、どちらも異なる LAN に接続されている想定です。したがって両者からアクセスできる Global IP をもつサーバが 1 つ必要になります。

次の図のイメージです。

![](/images/wireguard-remote-access-vpn.jpg)

単純な手を使えば Peer A -> Peer C -> Peer B と SSH を繋げて行けばよいでしょうし、`iptables` などをいじれば Peer A (-> Peer C) -> Peer B も実現できそうです。

## おわりに

WireGuard の QuickStart から、WireGuard の役割を整理しました。

VPN という言葉の定義が私の中で曖昧だったために無駄に混乱しましたが、
**WireGuard を利用すればモダンな VPN の構築ができ、これを応用すればリモートアクセス VPN を構築できる**
ということでよさそうです。

もし余裕があれば、 WireGuard と AWS EC2 を利用して、実際にリモートアクセス VPN を構築する手順も整理したいと思います。
