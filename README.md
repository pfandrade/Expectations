# Expectations
A short & sweet expectation implementation written in Swift. See the [blog post](https://pfandrade.me/blog/building-expectations/) for the rationale behind it.

This is similar to using an XCTestExpectation.

## Usage

Simply create an expectation, pass it to an asynchronous task and wait on it.

```swift
let expectation = Expectation()
someAsynchronousMethodCall() {
    expectation.fulfill()
}

expectation.wait(for: 5)
```

## Installation

It's just a single file, copy it to your project and you're done.
