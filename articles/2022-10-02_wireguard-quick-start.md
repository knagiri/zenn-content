---
title: 'リモートアクセスVPNを構築したいのでWireGuardを調べる'
emoji: '🐉'
type: 'tech' # tech: 技術記事 / idea: アイデア
topics: ['wireguard']
published: false
---

自宅内のデスクトップに外部ネットワークから接続したかったので，先日 WireGuard x EC2 を利用した VPN を構築する計画をたてました．

WireGuard QuickStart だけだと，イマイチ VPN 構築のイメージが湧きませんでしたので，こちらにその補足的なメモです．

## はじめに

:::message
インフラ・セキュリティ等の初学者です．誤りなどがありましたら，ご指摘お願いします．
:::

## WireGuard とは？

WireGuard の詳細な説明は[WireGuard 公式](https://www.wireguard.com/)や他の方の説明力を多分に頼ることにします．

WireGuard の特徴はこちらによくまとまった記事がありました．
https://zenn.dev/hiroe_orz17/articles/f8f35075dea4cf

またこちらの動画にはセキュリティについてもわかりやすい説明がありました．

https://youtu.be/grDEBt7oQho?list=TLGGLG3hlt_Af5EwMTEwMjAyMg

ということで，私は WireGuard の QuickStart がイマイチピンと来なかったので，それについて整理します．

### QuickStart

WireGuard 公式の QuickStart に「Side by Side Video」というセクションが用意されています．2 分半ほどの動画ですので見てみてください．

#### ざっくり整理

概ねやっていることは同じなので Peer A（動画左側）について整理します．

1. 秘密鍵（及び公開鍵）を作成

2. 「 WireGuard 用の Network Interface = `wg0` 」を作成する

3. `wg0` に VPN で利用する IP アドレス(`10.0.0.1/24`)を指定する

   - VPN 上で Peer A は`10.0.0.1/24`のアドレスをもちます

4. `wg0`の通信において，WireGuard が利用する秘密鍵を指定する

5. `wg0` を起動し，`wg0`に指定した IP アドレス(`10.0.0.1/24`)と実際の通信に利用している IP アドレスが`192.168.1.1/24`であることを確認する

6. Peer A を Peer B と通信可能にする
   - 認証のために Peer B の公開鍵を指定する
   - 特定範囲の IP アドレス(`10.0.0.2/32`)への通信を Peer B(`192.168.1.2:51820`)への通信として処理する
   - これは Peer A -> Peer B のための設定であると同時に，Peer B -> Peer A を許可するための設定でもある．

...上記の設定後，ping が走る時のイメージはこんな感じでしょうか．

![](/images/wireguard-quickstart.jpg)

元々の ネットワーク(`192.168.1.0/24`)の代わりに，WireGuard より構築した IP アドレス(`10.0.0.0/24`)を利用して通信をしているように見えますね．

ここで構築したネットワークを VPN と呼ぶ認識で問題なさそう．

## 結局，WireGuard とは？

「Peer A -> Peer B の接続が可能なとき，Peer A <-> Peer B の通信が可能なネットワークを構築できるツール」
という解釈でどうでしょうか．

ここまでざっくり整理したとおり，各 Peer では通信相手となる Peer のエンドポイントを指定する必要がありましたね．

Peer A -> Peer B さえ通信できれば，WireGuard がよしなにして Peer B -> Peer A の通信を可能としてくれるみたいです．

### あれ？

さて，ここで当初の目的に立ち戻ってみましょう．

当初の目的は Peer A - Peer B を接続することでした．どちらも異なる LAN 環境にある機器なので，Peer A -> Peer B ができなかったわけです．

これを接続できるようにするために VPN を構築してみることにしました．WireGuard を利用するのがよさそうです．

そして WireGuard を利用するには Peer A と Peer B の通信が可能でなくてはならない．

...こんがらがってきましたね．

## 異なるネットワーク間での VPN 構築について

WireGuard は確かに「VPN = 仮想プライベートネットワーク」を構築してはいるものの，
これだけで「いわゆる VPN = リモートアクセス VPN = 異なるネットワーク上のノード間接続が可能なネットワーク」を可能とするわけではないんですね．

私が構築したいのは「リモートアクセス VPN」，WireGuard が構築できる「VPN」とは区別して呼ぶべきでした．

ひとまず Global IP を持つサーバを用意すれば，「リモートアクセス VPN」を実現できそうです．

![](/images/wireguard-remote-access-vpn.jpg)

単純な手を使えば Peer A -> Peer C -> Peer B と SSH を繋げて行けばよいでしょうし，iptables などをいじれば Peer A (-> Peer C) -> Peer B も実現できるでしょう．

リモートアクセス VPN 実現のイメージはしっかり湧いてきまして，WireGuard の霧がよく晴れました．

早速構築していきたいところですが...，ちょっと長くなってきたのでこの記事はここまで．

## おわりに

こちらの記事では WireGuard の QuickStart から，WireGuard の役割を整理しました．

VPN という言葉の定義が私の中で曖昧だったために無駄に混乱しましたが，

「WireGuard を利用すればモダンな VPN の構築ができ，これを応用すればリモートアクセス VPN を構築できる」

ということでした．

次回の記事では WireGuard x AWS EC2 を利用して，実際に自分用の VPN を構築してみようと思います．

以上，WireGuard と VPN のもやもや解消でした〜〜〜
