---
layout: post
title: The Keycard hardware wallet smartcard explained
cover: /assets/images/covers/keycard-explained.jpg
tags:
- keycard
- hardware wallet
- ethereum
- smartcard
---

> [Keycard](https://keycard.tech/) is a smartcard that comes with two pre-installed applications, the one the you use as an **hardware wallet paired with
your devices and authenticated with a PIN**, and the **Cash applet**, which can be used **straight away without any other device**.

Keycard is a smartcard, not to be confused with other nfc tags or cards used only for storage or authentication.
It works like other hardware wallets, meaning that it's able to generate a private key that never leaves the card and can compute an
ECDSA signature internally.

Smartcards are known for their very high level hardware security, leveraging all the work done in the banking/telecom/access control world for years,
allowing us to store wallet keys safely in that they never leave the card.
The [Keycard software](https://github.com/status-im/status-keycard) is an open-source Javacard applet.
All sensitive data exchanged between the card and the client, like authentication credentials, is sent over an encrypted secure channel.
The applet allows deriving keys and signing transactions for any cryptocurrency using the Secp256k1 curve and a 256-bit hash.


The two application pre-installed are the Keycard applet and the Cash applets.

The **Keycard applet** implements a full hierarchical deterministic wallet that can be used after pairing the card with a device using a
pairing password that generates a pairing token subsequently used to open a [secure channel for each session to prevent MITM](https://status.im/keycard_api/sdk/securechannel.html);
after initialization the card contains a master key that remains on the card;
an API allows the user to use any valid derivation path to derive a key
that can be used to sign 32 bytes of data after authenticating with a PIN.

The **Cash applet** is a simplified version of the Keycard applet; at installation time a normal (not extended) key is generated and it remains on the card;
it doesn't need to be paired or initialized with another device and can be used straight away to sign data.

---

## About Keycard

Some months ago we started distributing Keycards to developers, and in October we had a workshop at Devcon 5.

<blockquote class="twitter-tweet"><p lang="en" dir="ltr">preparing some smartcards for tomorrow&#39;s <a href="https://twitter.com/Keycard_?ref_src=twsrc%5Etfw">@Keycard_</a> workshop here at <a href="https://twitter.com/hashtag/devcon?src=hash&amp;ref_src=twsrc%5Etfw">#devcon</a> 🇯🇵 <a href="https://t.co/oG6N2TrM6B">pic.twitter.com/oG6N2TrM6B</a></p>&mdash; Andrea Franz (@gravityblast) <a href="https://twitter.com/gravityblast/status/1181470270147588096?ref_src=twsrc%5Etfw">October 8, 2019</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

---

Some teams and developers already integrated Keycard in their projects,
like [Status](https://status.im/) (available after V1 is released), [Geth](https://twitter.com/peter_szilagyi/status/1135927489484791808?),
[Walleth](https://walleth.org/), [Gnosis Safe](https://twitter.com/StefanDGeorge/status/1189885553120104450),
[Grid+](https://github.com/GridPlus/safe-card), and others.

<blockquote class="twitter-tweet"><p lang="en" dir="ltr">One step closer to the Geth v1.9.0 release! Just merged native support for all these beauties on <a href="https://twitter.com/hashtag/Linux?src=hash&amp;ref_src=twsrc%5Etfw">#Linux</a>, <a href="https://twitter.com/hashtag/macOS?src=hash&amp;ref_src=twsrc%5Etfw">#macOS</a>, <a href="https://twitter.com/hashtag/Windows?src=hash&amp;ref_src=twsrc%5Etfw">#Windows</a> and <a href="https://twitter.com/hashtag/FreeBSD?src=hash&amp;ref_src=twsrc%5Etfw">#FreeBSD</a>! Shoutout to <a href="https://twitter.com/gballet?ref_src=twsrc%5Etfw">@gballet</a>, <a href="https://twitter.com/nicksdjohnson?ref_src=twsrc%5Etfw">@nicksdjohnson</a> and <a href="https://twitter.com/mr_ligi?ref_src=twsrc%5Etfw">@mr_ligi</a> for the team effort of sorting all this out! 😎<a href="https://twitter.com/hashtag/golang?src=hash&amp;ref_src=twsrc%5Etfw">#golang</a> <a href="https://twitter.com/hashtag/Ethereum?src=hash&amp;ref_src=twsrc%5Etfw">#Ethereum</a> <a href="https://twitter.com/Ledger?ref_src=twsrc%5Etfw">@Ledger</a> <a href="https://twitter.com/Trezor?ref_src=twsrc%5Etfw">@Trezor</a> <a href="https://twitter.com/Keycard_?ref_src=twsrc%5Etfw">@Keycard_</a> <a href="https://t.co/1jSj3QmHO1">pic.twitter.com/1jSj3QmHO1</a></p>&mdash; Péter Szilágyi (@peter_szilagyi) <a href="https://twitter.com/peter_szilagyi/status/1135927489484791808?ref_src=twsrc%5Etfw">June 4, 2019</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

---

The [Keycard software](https://github.com/status-im/status-keycard) is **completely opensource** and can be installed
on any smartcard/javacard that meets [these requirements](https://status.im/keycard_api/applet_installation.html#Card-requirements).

<blockquote class="twitter-tweet"><p lang="en" dir="ltr">Magic with <a href="https://twitter.com/Keycard_?ref_src=twsrc%5Etfw">@Keycard_</a> and <a href="https://twitter.com/gnosisSafe?ref_src=twsrc%5Etfw">@gnosisSafe</a>: A true 2FA transaction is signed with a private key on the phone and in addition with a private key in a secure enclave on the Status keycard. The most easy-to-use multisig! It also works with dApps using <a href="https://twitter.com/WalletConnect?ref_src=twsrc%5Etfw">@WalletConnect</a>! <a href="https://t.co/zs8TjyClW1">https://t.co/zs8TjyClW1</a></p>&mdash; Stefan George (@StefanDGeorge) <a href="https://twitter.com/StefanDGeorge/status/1189885553120104450?ref_src=twsrc%5Etfw">October 31, 2019</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

---

Keycard is dual interface, NFC and contacts. You can interact with it selecting one of the two applets
and sending [APDU commands](https://en.wikipedia.org/wiki/Smart_card_application_protocol_data_unit).
If you don't want to send raw APDU command, you can use our [Java/Android](https://github.com/status-im/status-keycard-java),
[Swift/iOS](https://github.com/status-im/Keycard.swift), and [Go](https://github.com/status-im/keycard-go) SDKs.

If you want to know more about the available commands, you can check the [Keycard API documentation](https://status.im/keycard_api/).

When you buy a Keycard from [our website](https://get.keycard.tech/), you receive it with the Keycard and Cash applets pre-installed,
but you can use the [keycard CLI](https://github.com/status-im/keycard-cli) to re-install them or to install them on a different smartcard.
You can also use the CLI to send custom Keycard or standard Globalplatform commands,
like explained in an [introductory post](https://discuss.status.im/t/introducing-the-keycard-shell/1178).

The main purpose of the Keycard is to be used as an hardware wallet with the Keycard applet, but we recently added a secondary Cash applet
that allows the owner to use it straight away without requiring a phone, for example to be used with a merchant point of sale or in
any other creative way...

<blockquote class="twitter-tweet"><p lang="en" dir="ltr">Simple test app for a point of sale machine 💰 signing a meta transaction with the 💳 <a href="https://twitter.com/Keycard_?ref_src=twsrc%5Etfw">@Keycard_</a> cash applet 💵. The cash applet is a secondary app, the main one is still the hardware wallet app 🔐 that needs pairing password, pin, etc <a href="https://twitter.com/hashtag/ethereum?src=hash&amp;ref_src=twsrc%5Etfw">#ethereum</a> <a href="https://twitter.com/hashtag/smartcard?src=hash&amp;ref_src=twsrc%5Etfw">#smartcard</a> <a href="https://twitter.com/hashtag/hardwarewallet?src=hash&amp;ref_src=twsrc%5Etfw">#hardwarewallet</a> <a href="https://t.co/Q9sISLoKwo">pic.twitter.com/Q9sISLoKwo</a></p>&mdash; Andrea Franz (@gravityblast) <a href="https://twitter.com/gravityblast/status/1197191210244411393?ref_src=twsrc%5Etfw">November 20, 2019</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

---

...or just with a phone that a merchant wants to use as a point of sale:

<iframe width="560" height="315" src="https://www.youtube-nocookie.com/embed/RU8IN7kNSBQ" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

---

## The Keycard Applet

When you receive the card the applet is installed but not initialized.
This means that it doesn't contain any key, and it needs to be initialized to be able to sign transactions.
During the initialization process we generate some secrets that we'll need
later to use the card:

* a pairing password needed to pair the card to a device.
* a PIN needed to sign data and transactions (and for other commands).
* a PUK needed to reset the PIN.

After initialization the card is ready to be paired with a device using the secrets generated in the previous step.

Once initialized, we can generate a new key with the [GENERATE KEY command](https://status.im/keycard_api/apdu/generatekey.html).
In other cases, it's also possible to import a normal key, an extended key,
or a seed derived from a mnemonic phrase following the [BIP39](https://github.com/bitcoin/bips/blob/master/bip-0039.mediawiki).

Now that we have a master key, we can sign any 32 bytes of data with the derivation path we want
after authenticating with the PIN generated during initialization.

## The Cash Applet


