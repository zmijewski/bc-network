---
title: 001. P2P communication over TCP
status: accepted
---

## Context

In order to make the blockchain propagate information quickly and relatively safely we need to use TCP protocol over HTTP.

## Decision

Communication interface should have relatively easy interface and allow to replace with other protocols when needed.

## Consequences

Implementation will be more complex than by using HTTP but still more safer than with usage of UDP protocol.

Team needs to learn how to use TCP protocol and build a client and server from scratch.
