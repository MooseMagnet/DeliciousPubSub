# Delicious PubSub

A strongly-typed PubSub library for Swift. It's delicious _and_ nutritious, so my parents will stop being disappointed in me.

## Overview

With Delicious PubSub, you subscribe to messages by type... _any_ type! It uses Swift's rather limited reflection API to map types to enlisted callbacks using the type's name... so really it just manages a dictionary of Strings to Functions.

There are several ways to enlist subscribers (when I'm done writing this there will be plenty of examples below), but they all come back to this function:
`sub<T: Any>(fn: T -> Void) -> Void -> Void`

`sub` takes a closure which accepts a single argument of the type of message you're subscribing to. This closure is added as a handler for that message type, and it will be invoked with an instance of the message type when the message is dispatched.

`sub` returns an unsubscribing function which simply removes the enlisted handler from the PubSub object's list of handlers. When you want your handler to stop handling dispatched messages, just invoke the function returned by the corresponding `sub` call.

There's only one way to publish a message.
Use `pub(message: Any)`.

There's another public function, `dispatchMessages()`, which will be explained later...

When a PubSub object is deinitialized, all of it's handlers are removed.
This releases references to the closures and any enclosed

## Usage

### Subscribe to messages as classes

This example demonstrates subscribing to messages by class. It also shows how to unsubscribe, though in this example you wouldn't need to.

```swift
class SecretMessage {
	let secret: String
    init(secret: String) {
    	self.secret = secret
    }
}

let pubSub = PubSub()

let unsubscribe = pubSub.sub(SecretMessage.self) {
	print("Wow. A secret message. It says '\($0.secret)'...");
}

pubSub.pub(SecretMessage(secret: "I hate you"))

unsubscribe()
```

### Subscribe to messages as primitives

You can subscribe to messages by any type, which means you can technically use primitives like Double, Int, Bool, String... I'm not saying you _should_, but you totes _can_... just make sure no one's watching. That's how I do most things in life.

```swift
let pubSub = PubSub()

let _ = pubSub.sub { (int: Int) in
	print("\(int) is the loneliest number...")
}

pubSub.pub(1)
```

Bit weird, huh.

### Predicated subscriptions...

You can control the execution of your subscription callbacks with pre-conditions. I dunno, maybe you only care about secret messages that start with the letter "S".

```swift
let pubSub = PubSub()

let _ = pubSub.sub(
    SecretMessage.self,
    predicate: {
        $0.secret.hasPrefix("S")
    },
    fn: {
        print("'\($0.secret)' starts with S and I like that. A lot...")
    })

pubSub.pub(SecretMessage(secret: "ABC"))
pubSub.pub(SecretMessage(secret: "123"))
pubSub.pub(SecretMessage(secret: "@(*&$@)#($&*#@"))
pubSub.pub(SecretMessage(secret: "Spongey old grapes!"))
pubSub.pub(SecretMessage(secret: "sludge magnet"))
```

### One-time subscriptions

You can add one-time subscriptions to messages using the `subOnce` functions. The callbacks will be invoked once, and immediately unsubscribe themselves. Like `sub`, `subOnce` also returns an unsubscribing function. You can invoke it to prematurely cancel your subscription and prevent the handler from ever running.

```swift
let pubSub = PubSub()

let actuallyNoIChangedMyMind = pubSub.subOnce(String.self) { _ in
	fatalError("This will never be called!")
}

actuallyNoIChangedMyMind()

pubSub.pub("RAAARRRRR..... I hate myself.")
```

With predicatd subscriptions, you can listen for and respond to only the first occurrence of a message that satisfies a precondition, and then never think about it again.

```swift
let pubSub = PubSub()

let _ = pubSub.subOnce(
	Int.self,
    predicate: { $0 <= 1 },
    fn: { _ in print("Hooray.") })

pubSub.pub(3)
pubSub.pub(2)
pubSub.pub(1)
pubSub.pub(0)
```

## Message dispatch

You may have noticed you can initialize a PubSub object with or without supplying an argument for `dispatchImmediately`.

By default, the value for `dispatchImmediately` is true.
What does it do?

If `dispatchImmediately` is true, then any published message will be immediately (as in, before the `pub` function returns) dispatched to any and all subscribers of that message's type.

However, if `dispatchImmediately` is false, then published messages will not be dispatched until you explicitly invoke `dispatchMessages()` on your PubSub object.

In most cases you probably won't have to worry about it and therefore can use the default behaviour. If you find yourself wanting to accumulate published messages and have some control over when they will be handled, then go ahead and `let pubSub = PubSub(dispatchImmediately: false)` and `pubSub.dispatchMessages()` whenever you're ready.

With manual dispatch, subscribers enlisted after messages have been published will see those messages when the dispatch eventually does occur. Something to think about.

```swift
let pubSub = PubSub(dispatchImmediately: false)

pubSub.pub(1)
pubSub.pub(2)

let _ = pubSub.sub { (int: Int) in
	print("Yay, the number \(int)! How exciting.")
}

pubSub.pub(3)

pubSub.dispatchMessages()
```

You get the picture.

## So many PubSubs

Each PubSub object manages it's own subscribers and therefore you can have as many as you like; there's no shared / global state so your subscriptions won't conflict. This probably goes without saying.

```swift
let pubSub1 = PubSub()
let unsub1 = pubSub1.sub { (int: Int) in print("pubSub1 got \(int)") }

let pubSub2 = PubSub()
let unsub2 = pubSub2.sub { (int: Int) in print("pubSub2 got \(int)") }

pubSub1.pub(1)
pubSub2.pub(2)

unsub1()

pubSub1.pub(1)
pubSub2.pub(2)

unsub2()

pubSub1.pub(1)
pubSub2.pub(2)
```

## Performance

Here are some stats of handling one message type with handlers that do nothing when invoked (i.e. empty function bodies).

10,000 messages each dispatched to 1000 subscribers: ~7.933 seconds  
10,000 messages each dispatched to 100 subscribers: ~1.155 seconds  
100 messages each dispatched to 100 subscribers: ~0.011 seconds  
100 messages each dispatched to 10 subscribers: ~0.002 seconds

You can use GCD in your handlers if you have long-running or latent operations executing in them. The act of dispatching via GCD incurs it's own overhead.

### Sub overloads and type inference.

You'll notice there is an overload for each function to add a subscriber with a `type: T.Type` param.

It's is there purely for stylistic purposes. With Swift's type inference it's entirely unnecessary in every case, but everyone has their opinion about what does/n't look nice, so, uhh... do whatever you want.

```swift
let pubSub = PubSub()

let _ = pubSub.sub(String.self) {
		print($0)
}

let _ = pubSub.sub { (string: String) in
		print(string)
}

let _ = pubSub.sub(
		String.self,
		predicate: { $0.hasPrefix("A") },
		fn: { print($0) })

let _ = pubSub.sub(
		predicate: { (string: String) in string.hasPrefix("A") },
		fn: { print($0) })
```

### Some notes about unsubscribing

I didn't know where to put this so here it is, at the end.

You can call an unsubscribing function multiple times. It will only do anything once.

You can call an unsubscribing function inside of another handler. If that handler runs before the handler you want to deregister is called, then it'll work out just fine... Here's an example...

```swift
let pubSub = PubSub()

var unsub: (Void -> Void)!

let _ = pubSub.sub { (_: Int) in
    unsub()
}

unsub = pubSub.sub { (_: Int) in
    fatalError("This should never happen.")
}

pubSub.pub(1)

unsub()
```

## That's all there is.

If you don't like it, then let me know why.

If you want to improve it, then submit a PR. I'm sure you'll do a better job than I would.
