---
layout: post
title: NFT built-in Swap Market with gasless listing
cover: /assets/images/covers/cyber.jpg
share_image: /assets/images/cyber-tarot/CyberTarotNFT-full.gif
tags:
- nft
- ethereum
- smart-contracts
---

More than a year ago I was working on a [Token Redeem dApp](https://github.com/status-im/keycard-redeem)
for the [Keycard Hardware Wallet](https://keycard.tech/) that supported both **ERC20** and **ERC721** tokens.
While working on that I had the idea of adding some **gamification** to a standard **ERC721 contract**:
something similar to what I used to do when I was younger, **swapping NBA cards with friends** to collect all the players of my favourite team.

If we think of the full collection of those cards as an ERC721 collection, the players' team can be thought as a **trait type** of
that NFT.

There are many platforms that allow **to buy and sell NFTs**, but what I wanted to add was a way to be able to **list my cards
without paying gas**, and to **swap them atomically** with other cards with some **specific traits I like**, to include them in my collection.

If all or some of the **traits are on chain**, it's easy to implement a swap with some kind of **trait validation**.
And anyone can list their cards simply using a signature,
following the same pattern as the one used in the [EIP-2612 permit](https://eips.ethereum.org/EIPS/eip-2612) function.

Moreover, we can add some **swap rules** in the [EIP-721 message](https://eips.ethereum.org/EIPS/eip-712) that validate
the swap based on the traits I like.

## Example:

* Alice has card `1` and `2` both with trait `A` and she wants a card with trait `B` **OR** `C`.
* She signs a message that says: "card `1` can be swapped with any card with trait `B` **OR** `C`".
* The message and signature can be saved on a centralized server or shared by Alice with friends.
* Bob receives the signature and sends it with a transaction to the contract specifying the id of the cards he wants to swap.
* The contract checks if Bob's card is either a `B` or `C`, and swap the cards atomically.

The rule can be a simple bitstring like:

* `0001` (swappable only with trait A)
* `0011` (swappable only with trait A **or** B)
* `1011` (swappable only with trait A, B, **or** D)

I like this idea because it adds more dynamics for collectors, even if it can be very specific to each project and cannot really be
used as a standard. Nevertheless, I decided to start a new [project](https://cybertarotnft.com) to test it,
together with my friend and favourite artist [Royb](https://twitter.com/ROYB_Art).

For both of us this has been a side project, and therefore it took many months to be completed,
but in this long journey we learnt a lot and finally we are happy to announce that this new idea will be launched soon!

## CyberTarot NFT

When he joined the team, Royb was working on some artwork inspired by the Tarot Major Arcana cards, so we decided to build our project along
the same lines as the [Tarot Cards Games](https://en.wikipedia.org/wiki/Tarot_card_games).

This initial concept was conceived with special focus on the Art itself and on the Swap Market in order to convey some initial level of gamification,
while leaving the development of a full game for the future,
hopefully by sponsoring people from the community to contribute to it.

![Cyber Tarot Drawings](/assets/images/cyber-tarot/cyber-tarot-2.jpg)

![Cyber Tarot Drawings](/assets/images/cyber-tarot/cyber-tarot-3.jpg)

We named it [CyberTarot](https://cybertarotnft.com), and Royb started producing some amazing work,
with more than 450 drawings that together built a collection of 580 unique traits and 10K
CyberTarot Minor Arcana.

Each one of these Minor Arcana, amongst its many traits, has **a rank and a suit** based on the token id.
And since the token id is available to the **Swap Market**,
they can be used as **swap rules** as described above.
By swapping cards, collectors will be able allow to create **mini decks** with cards ranked from 0 to 9,
or **royal** mini deck if they follow the same suit.

![Cyber Tarot Preview](/assets/images/cyber-tarot/CyberTarotNFT-full.gif)

The second phase of the project will be the deployment of the **22** fractionalized
Major Arcana, whose shares can be minted only by owning a **mini deck**.

![Cyber Tarot Drawings](/assets/images/cyber-tarot/cyber-tarot-1.jpg)

We hope that this project is well received by the NFT community.
Our goal has been to make it innovative and different from the usual PFPs,
by adding much more diversification and value to the art,
as well as by introducing gamification dynamics that we are really excited to see in action soon.

If this project has gotten you excited like we are,
please share this post and follow/share our [CyberTarotNFT Twitter account](https://twitter.com/CyberTarotNFT).

If you want to collaborate and help build a community around the CyberTarot, [please slide in my DM](https://twitter.com/gravityblast) :).

happy hacking.
