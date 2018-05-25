# Rusty's Remarkably Unreliable Guide To Bitcoin Storage: 2018 Edition

## About This Guide

This is an opinionated guide to storing your bitcoin securely.  You
should read this before buying bitcoin.

I wrote this because existing guides are all aimed at experts<sup>[1](#gmax-offline)</sup>,
assume knowledge you might not have, or skip over important things
like backups, or actually spending your bitcoin.

## Check You Have The Right Guide!

This guide is digitally signed by me: you can download it from
[github](https://github.com/rustyrussell/bitcoin-storage-guide/tags)
where you should see a green "Verified" next to the latest version.

For the technically inclined you can also find my GPG fingerprint
here, and my signature on this document in README.md.sig (`gpg --verify README.md.sig README.md`)

* [Keybase](https://keybase.io/rusty)
* [Twitter](https://mobile.twitter.com/rusty_twit/status/644559490646278144)
* [My blog](https://ozlabs.org/~rusty/rusty-gpg.asc)

## About The Author

I'm Rusty Russell, a Linux kernel hacker best known for writing
iptables.  I stumbled into bitcoin a few years ago and promptly got
distracted by all the cool technology; I ended up employed by bitcoin
innovation developers Blockstream because I told them bitcoin is like
Linux and I know Linux (no, really!).

Part of this salary deal was about $5000 of bitcoin per year, paid
monthly after the first year.  I decided to
document what I'm doing in the hope that greater minds will provide
feedback on what I did wrong.  And then return my coins please...

# Getting Started

Bitcoins are digital cash; if you get my private key (a big, long,
secret number), you can spend my bitcoins from anywhere in the world.
This makes me nervous, and it should make you nervous too.

Letting someone else hold my coins isn't viable either: the history of
bitcoin is one of scams and hacks, and it will take decades before we
have any idea which bitcoin services are reliable, and which will
collapse and take the funds with them.

There are four main concerns for those holding bitcoin:

1.  **Failure**: All bitcoins will become worthless.
    This is a real possibility, but I can't help you with this one.
2.  **Loss**: I will lose my private key and nobody will be able to spend the coins.
3.  **Theft**: Someone will steal my private key and take my coins.
4.  **Inconvenience**: It will be really hard for me to spend my coins when I want to.

Loss protection, theft protection and convenience are all competing
goals, so I'm going to provide a quick guide:

1.  Beer money.  For less than $50, I'd keep it in any online wallet
    you want.
	* Risks: they could get hacked, go bankrupt, or stop your account.
	* Pros: really easy to use.

2.  Small investment.  For less than $10000, my preference would be
    any service which doesn't control your keys, say using 2 of 3
    multi-sig, where you control 2 and they control 1.  I've only got
	experience with the
    Greenbits wallet for Android<sup>[2](#greenbits-android)</sup> (you can also use Green Address's Chrome
    app<sup>[3](#greenaddress)</sup>).  Their initial setup UX is mediocre, but they provide two
    factor for spending above your chosen limit, ability to save your
    wallet phrase in case you lose your phone, a failsafe if they
    ever vanish, and they don't have access to your coins.
	(Disclaimer: I have Blockstream stock, and they own GreenAddress).

	* Risks: if you use SMS verification on the same phone as the
	  Greenbits wallet, software which hacks your phone could
	  intercept that and spend your money.  If you use a different
	  method (eg. phone for SMS verification, laptop Chrome for the
	  app), the hacker would have to hack both phone and laptop.
	* Pros: almost as easy to use.

3.  Larger investment.  For less than $50000, you could use a
    hardware wallet with a screen.  The main options here are
    the Trezor<sup>[4](#trezor)</sup> and the Ledger<sup>[5](#ledger)</sup>; it's probably possible to extract the secret key from
    the device, but it'd be fairly hard (thus, not worthwhile) and
	they'd almost certainly need physical access.

    * Risks: the device might be replaced (or "pre-initialized") before you get it.
	  If someone hacks your laptop, they could silently change
      the address where you're sending the funds, so you want to
      double-check the address using another device for large
      transfers.  They can't change the amount though.
	* Pros: still fairly easy to use.

4.  Serious investment.  For larger amounts, or the paranoid, a
    completely offline "safe" is a good idea.  That's what this
    document is mainly about, and this is what I'm doing: I plan on
    being at Blockstream for a while, and not spending the bitcoin.

	* Risks: someone hacks your offline machine before you take it offline,
	or someone substitutes the address you're sending the funds to and
	you pay to the wrong place, or you lose the private keys, or you get
	frustrated with how long it takes to spend bitcoin and make a mistake.
	* Pros: most secure against theft.

5.  More money than I will ever have.  For those carrying millions, I
    don't have any useful advice; you need to find a professional who
    won't steal all your money.

# Setting Up An Offline Safe

We're going to use bitcoin-core, the bitcoin reference software, to generate a few bitcoin addresses on a machine which has
no way of contacting the outside world, we're going to write down the
private keys on paper, we're going to double-check them, and we're
going to protect those pieces of paper.

## Create an Offline Safe

You will need:

* A pen
* Four pieces of paper
* Two USB keys (one least 2GB aka "big", one at least 4M aka "small").
* A laptop with two USB ports

### For The Extra Paranoid

The extra paranoid will destroy or never reuse those the USB keys in
any other machine, maim the laptop, ensure it stays offline forever or
destroy it: you can simply buy a cheap $200 laptop or use an old one.

### Step 1: Download and Prepare Ubuntu 18.04 (20 minutes)

Ubuntu is a simple, free operating system.  It's easy to install and
use, and downloaded thousands of times each day.  You can get it from
[http://releases.ubuntu.com/18.04/ubuntu-18.04-desktop-amd64.iso](http://releases.ubuntu.com/18.04/ubuntu-18.04-desktop-amd64.iso).
You will need a recent laptop (if it's over 10 years old, it might not
support 64 bit, and you'll get a message about "This kernel requires an x86-64 CPU").

You should check that you have the real Ubuntu, if you can.  On Linux
and MacOS this is easy, on Windows you'll need
[sha256sum.exe](http://www.labtestproject.com/files/win/sha256sum/sha256sum.exe).
Use the following commands to sum the file you downloaded, which should
match the example below:

* **MacOS**: shasum -a 256 /tmp/ubuntu-18.04-desktop-amd64.iso
* **Windows**: sha256sum.exe ubuntu-18.04-desktop-amd64.iso
* **Linux**: sha256sum /tmp/ubuntu-18.04-desktop-amd64.iso

This should give a number
<!--- sha256sum ubuntu-18.04-desktop-amd64.iso --->
`a55353d837cbf7bc006cf49eeff05ae5044e757498e30643a9199b9a25bc9a34`

If the number you get is different, STOP.  Something is badly wrong.

Now we need put it on the big USB, so we can install it on the cheap
laptop; here are instructions for
[Windows](https://www.ubuntu.com/download/desktop/create-a-usb-stick-on-windows),
[MacOS](https://www.ubuntu.com/download/desktop/create-a-usb-stick-on-mac-osx)
and
[Linux](https://www.ubuntu.com/download/desktop/create-a-usb-stick-on-ubuntu).

#### Extra Paranoia (Optional)

Use DVDs instead of the USB sticks, and a laptop which doesn't have a
DVD burner so you know it can never write anything back.

### Step 2: Putting bitcoin on the small USB key (10 minutes)

Format the small USB key and put the helper script which matches this HOWTO:

* [offline](https://raw.githubusercontent.com/rustyrussell/bitcoin-storage-guide/v0.3.0/offline)

You also need bitcoin and friends on the USB key:

* [bitcoind](https://launchpad.net/~bitcoin/+archive/ubuntu/bitcoin/+files/bitcoind_0.16.0-bionic1_amd64.deb)
* [libdb4.8++](https://launchpad.net/~bitcoin/+archive/ubuntu/bitcoin/+files/libdb4.8++_4.8.30-bionic3_amd64.deb)
* [libboost-chrono1.65.1](https://mirrors.kernel.org/ubuntu/pool/main/b/boost1.65.1/libboost-chrono1.65.1_1.65.1+dfsg-0ubuntu5_amd64.deb)
* [libboost-filesystem1.65.1](https://mirrors.kernel.org/ubuntu/pool/main/b/boost1.65.1/libboost-filesystem1.65.1_1.65.1+dfsg-0ubuntu5_amd64.deb)
* [libboost-program-options1.65.1](https://mirrors.kernel.org/ubuntu/pool/main/b/boost1.65.1/libboost-program-options1.65.1_1.65.1+dfsg-0ubuntu5_amd64.deb)
* [libboost-system1.65.1](https://mirrors.kernel.org/ubuntu/pool/main/b/boost1.65.1/libboost-system1.65.1_1.65.1+dfsg-0ubuntu5_amd64.deb)
* [libboost-thread1.65.1](https://mirrors.kernel.org/ubuntu/pool/main/b/boost1.65.1/libboost-thread1.65.1_1.65.1+dfsg-0ubuntu5_amd64.deb)
* [libevent-core](https://mirrors.kernel.org/ubuntu/pool/main/libe/libevent/libevent-core-2.1-6_2.1.8-stable-4build1_amd64.deb)
* [libevent-pthreads](https://mirrors.kernel.org/ubuntu/pool/main/libe/libevent/libevent-pthreads-2.1-6_2.1.8-stable-4build1_amd64.deb)
* [libminiupnpc10](https://mirrors.kernel.org/ubuntu/pool/main/m/miniupnpc/libminiupnpc10_1.9.20140610-4ubuntu2_amd64.deb)
* [libssl1.1](https://mirrors.kernel.org/ubuntu/pool/main/o/openssl/libssl1.1_1.1.0g-2ubuntu4_amd64.deb)
* [libzmq5](https://mirrors.kernel.org/ubuntu/pool/universe/z/zeromq3/libzmq5_4.2.5-1_amd64.deb)
* [libsodium23](https://mirrors.kernel.org/ubuntu/pool/main/libs/libsodium/libsodium23_1.0.16-2_amd64.deb)
* [libpgm-5.2-0](https://mirrors.kernel.org/ubuntu/pool/universe/libp/libpgm/libpgm-5.2-0_5.2.122~dfsg-2_amd64.deb)
* [libnorm1](https://mirrors.kernel.org/ubuntu/pool/universe/libp/libpgm/libpgm-5.2-0_5.2.122~dfsg-2_amd64.deb)
* [qrencode](https://mirrors.kernel.org/ubuntu/pool/universe/q/qrencode/qrencode_3.4.4-1build1_amd64.deb)
* [libqrencode](https://mirrors.kernel.org/ubuntu/pool/universe/q/qrencode/libqrencode3_3.4.4-1build1_amd64.deb)

#### Extra Paranoia (Optional)

(TECHNICAL USERS ONLY) Use the "tar" command (on MacOS or Linux) to
place the files directly onto the raw USB device, instead of using a
filesystem.  This avoids any potential filesystem exploits, and makes
it harder for other files to sneak on.

#### Extra Paranoia (Optional)

Physically remove the wireless and bluetooth cards in your laptop, as
well as the speaker.  This makes it almost impossible for your private
keys to leak out, even if the laptop were compromised somehow.

It won't help if they laptop has been physically compromised with a
secret transmitter, of course.  But we have to stop somewhere!

### Step 3: Booting Ubuntu on Your Laptop (10 minutes)

1. Find the "airplane mode" icon on the keyboard.  Mine is on F2;
   pressing "Fn" and F2 while the laptop is on should stop it
   transmitting anything.  If you don't have one, goto step 3.

2. Turn the laptop on, and activate airplane mode.  Then turn it off
   again.  We're going to leave it in airplane mode from now on.

3. Put the big USB into a USB port and turn the laptop on.  To make it
   start from that USB you usually need to hit F12, F2 or F1 during
   the boot sequence.  Google is your friend here, for your particular
   laptop (or there may be a message on the screen).

4. You'll see a black screen with some text.  You can select the "Try
   Ubuntu without Installing" option and hit return or simply wait.

5. You'll see a purple background with a dots blinking underneath
   the word Ubuntu as it boots up.  Eventually you'll see a desktop.  On
   the top right, you'll see 3 icons: left-click the top right, and
   you should see "Wi-Fi Not Connected".  Left-click on that, then
   click on "Turn Off".  Now you should see a little airplane on the
   top right of the screen.

5. Insert the small USB.

6. Start a terminal: we're going to do the rest as manual commands.  Do this
   by clicking on the dots at the far bottom left, and typing "term".
   You'll see a TV icon with a `>_` in it: click on this.  We're going
   to type into that box where it says `ubuntu@ubuntu:~$ `.

7. Let's make sure the script is the right one, and nobody has
   modified it.  Type the following then hit enter (it's a single line):

	  `sha256sum /media/ubuntu/*/offline`

   You should get the following result numbers and letters (ignore after the space).  If not, STOP, something is wrong.
<!--- sha256sum offline --->
	  `afc1503fdedb51adaa072719c8a54eafd59ea068311af487afea90033034059a  /media/ubuntu/USBKEY/offline`

8. Hit F11 to make the terminal full screen.

9. Run the script by typing: `python3 /media/ubuntu/*/offline`

### Step 4: Generating Some Private Keys (5 minutes)

1.  The script installs and runs the bitcoin program every time; it will complain
    if something goes wrong, and you should too.

2.  Make sure nobody can see your laptop screen.  No windows, no
    reflections.

3.  Type "create" then press enter.

4.  You will get an address like "342ftSRCvFHfCeFFBuz4xwbeqnDw6BGUey".
    Anyone can send bitcoin to this, and only the private key can
    spend it.  You will also get a private key like
    "L2b68o8EwXQQfWTu7K77Y7Pz9hLqzfb5vjVviJ8NadLXMWHdGYAv". This is a
    standard key you could import into other wallets later if you
    wanted to.

5.  Write down the public address(es) (3...) on one piece of paper,
    and write down the private key(s) (L... or K...) on three pieces
    of paper.  It shows you where to split the key into two or three
	parts, too.

6.  To generate more addresses and keys, you can do this as many times
    as you like.

### Step 5: Reboot and Check (5 minutes)

Let's make sure we wrote down that private key correctly!

1. Hold down the power button until the laptop turns off.  It will forget
   everything we've done.

2. Turn it back on, booting off the big USB key again.

3. Turn off networking, select "Try Ubuntu", put in the small USB key,
   open a terminal, press F11, and run `python3 /media/ubuntu/*/offline`.

4. Select "restore", and enter your private key (L... or K...).  If
   you got it correct, it should show you the public address which
   matches.  If you didn't, check for typos (you can use the left and
   right arrow keys to change your previous answer, and backspace to
   delete backwards).

5. Restore all the private keys you created to check them all.

6. Hold down the power button to turn the laptop off.

#### Extra Paranoia (Optional)

Never put those USB keys in another machine ever again, as it's
possible that malicious software on your laptop could have written
information about your keys to them.  Keep them with the laptop, and
never allow the laptop to go online ever again.

### Step 6: Store the Keys Safely

The public address (3...) you can write on the fridge, record in your
diary, or email to your own gmail account.  The only reason to keep
this secret is so that people don't know how many bitcoins you have.
You can get this back as long as you have your private key, anyway.

The private keys must never be disclosed.  They're about 52
letters-and-numbers long, and the first 1 and last 5 or 6 digits are
redundant, so if someone got most of the other 45 they could figure
out the rest.

A simple scheme would be splitting the three copies of the private key
into two pieces as shown by `offline`; keep the first parts at home, work,
and your parent's house.  The second parts at your friend's house, in
your handbag, and in a sealed envelope with instructions wherever your
will is stored (eg. with your lawyer).

## Sending Bitcoins to your Offline Safe.

Simply send to that public address.

For your own convenience when you come to spend it, you should record
the transaction ID, the amount sent, and which output went to your
public address: the first output is number 0, the second is number 1,
etc (it will usually send some change to another address as well,
hence two outputs).

### Extra Paranoia (Optional)

Use multiple addresses, and send randomized amounts at different times
on different days.  Divide it up roughly using random-looking numbers,
then for each one, flip a coin: if it's heads flip again.  If that's
heads, make it a round number of bitcoin, otherwise make it a round
number of USD at the current exchange rate.  This will blend in with
other transactions fairly well.

## Spending Bitcoins from your Offline Safe (20 minutes)

We will get your offline safe to create and sign a raw bitcoin
transaction, which you can send out onto the bitcoin network for
miners to include in blocks.

Bitcoin is essentially a ledger of payments: an incoming transaction
pays into your address, and you spend that by creating a transaction
which sends coins to a new address.  Your offline bitcoin progream obviously
doesn't know what transactions exist, so you need to tell it what
transaction paid you manually; it can be made to create a new
transaction and sign it<sup>[1](#gmax-offline)</sup>.  There's a quick way, and a slow way.

You'll need:

1. *Slow way*: the raw transaction which paid bitcoins into your
   address.  This looks like
   "0100000001344630cbff61fbc362f7e1ff2f11a344c29326e4ee96e787dc0d4e5cc02fd0690
   00000004a493046022100ef89701f460e8660c80808a162bbf2d676f40a331a243592c36d6b
   d1f81d6bdf022100d29c072f1b18e59caba6e1f0b8cadeb373fd33a25feded746832ec17988
   0c23901ffffffff0100f2052a010000001976a914dd40dedd8f7e37466624c4dacc6362d8e7
   be23dd88ac00000000".   And you'll have to type it all in without making mistakes.

2. OR *Quick way*: The amount, transaction ID and output number of the transaction
   which sent funds to your address.  A transaction ID looks like
   "a9d4599e15b53f3eb531608ddb31f48c695c3d0b3538a6bda871e8b34f2f430c"
   and you'll have to type it all in without making mistakes.
   If you didn't record this when you sent it, a block explorer should
   be able to find it if you give it your public address.  The first
   output is numbered "0", the second "1", etc.

3. The address you want to send the funds to.  For large amounts, you
   should get this address in two different ways, to make sure someone
   else hasn't substituted it with their own address.  This might mean
   getting it via your cell phone as well as a laptop, or even having
   the recipient read it out to you over the phone.

4. The fee rate you should pay to miners so they'll mine your
   transaction.  I have no idea what this will be: 5000 satoshi per
   kilobyte is currently reasonable.  Google for "bitcoin fee estimator"
   and you'll find several.

5. (Optional) Another address in your offline safe to send the
   change to, if you're not sending the entire amount.

6. A phone camera or QR code scanner to get the resulting transaction out.

Now you have those:

1. Turn your laptop on, booting off the big USB key again.  Turn
   off networking, select "Try Ubuntu", put in the small USB key, open
   a terminal, press F11, and run `python3 /media/ubuntu/*/offline`.

2. Restore the private key which received the payment.

3. Now enter the transaction you received (slow way) or the
   transaction ID (quick way).

4. Slow way: the program will now look through the transaction for
   which output paid to you, and how much it was.  If you typed the
   transaction wrong, it probably will fail to work when you try to broadcast
   the final transaction (it may simply fail to decode the transaction
   immediately, if you're lucky).

5. Quick way: you will tell it the output number and the amount that
   was sent.  If you get the output number or transaction ID wrong, it
   will fail when you try to broadcast the final transaction.  If you
   get the amount wrong it will also fail then.

6. Now enter the fee rate, and address to pay to.  Fees are required to
   get miners to include your transaction in a block.

7. Now enter the amount to send: to send it all (minus the fee), just
   hit enter.

8. If you didn't elect to send it all, enter one of your public
   addresses to receive the change.  I don't recommend reusing
   addresses, since that makes it obvious which output is payment and
   which is change.

9. It will complain if the change amount is tiny, or the fee amount
seems huge.

10. It will then describe the transaction; check this is correct.  If
    you elected to receive change, write down the transaction id,
    output and amount for spending in future.

11. Press Enter and it will then show you the completed, raw transaction
    as a QR code.  Google for "bitcoin send raw transaction" and
    you'll see various web sites where you can paste it in to send it
    to the bitcoin network.

12. If you don't want the transaction, don't send it: you can simply
    try again to create a new one.

### Extra Paranoia (Optional)

Run your own bitcoin full node somewhere (online).  Use `bitcoin-cli
importaddress 342ftSRCvFHfCeFFBuz4xwbeqnDw6BGUey` (except with your
own public key).  You can do this once for each address, and use
`bitcoin-cli getbalance` to see your bitcoins.  Use `bitcoin-cli
listtransactions "*" 1000 0 true` to show received and sent
transactions.  Use `bitcoin-cli getrawtransaction` to get a particular
raw transaction.  Use `bitcoin-cli estimatefee 6` to get the fee rate.

If you need to use a block explorer to find transactions, connect via
Tor.

# Final Words On Security

No security is perfect, but it's even more common for people to lose
their keys altogether.  Make sure your loved ones know your bitcoins
exist, and where to ask for help if you get struck by lightning.

Good luck!

Rusty.

# References and Other Resources

<a name="gmax-offline">[1]</a> [Greg Maxwell's offline signing example with bitcoin 0.7](https://people.xiph.org/~greg/signdemo.txt)

<a name="greenbits-android">[2]</a> [Greenbits Wallet for Android](https://play.google.com/store/apps/details?id=com.greenaddress.greenbits_android_wallet&hl=en) (NOT the older GreenAddress wallet, which has usability issues)

<a name="greenaddress">[3]</a> [Green Address](https://greenaddress.it/)

<a name="trezor">[4]</a> [The Trezor Hardware Wallet](https://bitcointrezor.com/)

<a name="Ledger">[5]</a> [The Ledger Hardware Wallet](https://www.ledgerwallet.com/)

# License

<a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/">
<img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-sa/4.0/88x31.png" /></a>
<br />This guide is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/">Creative Commons Attribution-ShareAlike 4.0 International License</a>.

The offline script is licensed under CC0 (public domain).
