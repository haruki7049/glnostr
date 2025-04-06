pub type Event {
  Event(
    id: BitArray,
    pubkey: BitArray,
    timestamp: Int,
    kind: Int,
    tags: List(String),
    content: String,
    sig: BitArray,
  )
}
