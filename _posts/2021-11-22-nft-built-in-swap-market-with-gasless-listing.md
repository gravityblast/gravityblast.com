---
layout: post
title: NFT built-in Swap Market with gasless listing
cover: /assets/images/covers/cyber.jpg
tags:
- nft
- ethereum
- smart-contracts
---

More than a year ago a was working on a [Token Redeem dApp](https://github.com/status-im/keycard-redeem)
for the [Keycard Hardware Wallet](https://keycard.tech/) that supported both **ERC20** and **ERC721** tokens.
While working on that I had an idea to add some **gamification** to a startdard **ERC721 contract**, based on the experience
I had when I was younger and **swapping NBA cards with friends**, trying to collect all the players of my favourite team.

If we think of the full collection of those cards as an ERC721 collection, the player's team can be thought as a **trait type** of
that NFT.

There are many platforms around that allow **to buy and sell NFTs**, but what I wanted to add was a way to be able to **list my cards
without paying gas**, and being sure to **swap them atomically** with another card with some **specific traits I like**.

If all or some of the **traits are on chain**, it's easy to implement a swap with some kind of **trait validation**.
And anyone can list their cards simply with a signature,
following the same pattern used in the [EIP-2612 permit](https://eips.ethereum.org/EIPS/eip-2612) function.

Moreover, we can add some **swap rules** in that [EIP-721 message](https://eips.ethereum.org/EIPS/eip-712) that validate
the swap based on the traits I like.

## Example:

* Alice has card `1` and `2` both with trait `A` and she wants a card with trait `B` or `C`.
* She signs a message that says: "card `1` can be swapped with any card with trait `B` or `C`".
* The message and signature can be saved on a centralized server or shared by Alice with friends.
* Bob receive the signature and sends it with a transaction to the contract specifying the id of the cards he wants to swap.
* The contract checks if Bob's card is either a `B` or `C`, and swap the cards atomically.

The rule cna be a simple bitstring like:

* `0001` (swappable only with trait A)
* `0011` (swappable only with trait A or B)
* `1011` (swappable only with trait A, B, or D)

I like this idea because it adds more dynamics for collectors, but it can be very specific to each project and cannot really be
a standars, so I decided to start a [project](https://cybertarotnft.com) to test it, and my friend and favourite artist [royb](https://twitter.com/ROYB_Art)
joined the team.

Since it's a side project it took many months, but in this long journey we learnt a lot of things and we are happy to say that we can launch it soon.

## CyberTarot NFT

Royb was working on some artwork based on the Major Arcana of the Tarot, and we decided to base our project on
[Tarot Cards Games](https://en.wikipedia.org/wiki/Tarot_card_games), focusing more on the **art and Swap Market** to have
some initial gamification, and leaving the development of a full game for the future, maybe funding some people from the community to do it.

![Cyber Tarot Drawings](/assets/images/cyber-tarot/cyber-tarot-1.jpg)

We decided to call it [CyberTarot](https://cybertarotnft.com), and Royb made some amazing artwork,
with more than 450 drawings allowing the collection to have 580 unique traits and 10K
CyberTarot Minor Arcana.

Each one of them, among those many traits, has **a rank and a suit** based on the token id. And since the token id is available to the **Swap Market**,
they can be used as **swap rules** as described above. Swapping cards allow to create **mini-decks** with cards ranked from 0 to 9,
that can be **royal** mini-deck if they also have the same suit.

![Cyber Tarot Preview](/assets/images/cyber-tarot/CyberTarotNFT-full.gif)

The second phase of the project will be the deployment of the fractionalized Major Arcana where their shares can be minted only by owning a mini-deck.

![Cyber Tarot Drawings](/assets/images/cyber-tarot/cyber-tarot-1.jpg)

We hope the NFT community likes this project. We tried to make it different from the usual PFPs adding much more diversification to the drawings,
and some gamification dynamics that we would love to see in action.

If you like it, please share this post and follow/share our [CyberTarotNFT Twitter account](https://twitter.com/CyberTarotNFT).

If you want to collaborate and help building a community around the CyberTarot, [please slide in my DM](https://twitter.com/gravityblast) :).

gm and happy hacking.
