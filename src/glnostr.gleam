import gleam/bit_array
import gleam/crypto
import gleam/json.{type Json}

/// NIP-01 Event structure
pub type Event {
  Event(
    id: BitArray,
    pubkey: BitArray,
    created_at: Int,
    kind: Int,
    tags: List(List(String)),
    content: String,
    sig: BitArray,
  )
}

/// Create a new event with a calculated ID (hash).
/// Note: The signature is left empty and must be signed separately.
pub fn create_event(
  pubkey: BitArray,
  created_at: Int,
  kind: Int,
  tags: List(List(String)),
  content: String,
) -> Event {
  let id = calculate_id(pubkey, created_at, kind, tags, content)

  Event(
    id: id,
    pubkey: pubkey,
    created_at: created_at,
    kind: kind,
    tags: tags,
    content: content,
    sig: <<>>,
  )
}

/// Calculate the event ID (SHA256 of the serialized event).
pub fn calculate_id(
  pubkey: BitArray,
  created_at: Int,
  kind: Int,
  tags: List(List(String)),
  content: String,
) -> BitArray {
  let serialized = serialize_for_id(pubkey, created_at, kind, tags, content)

  crypto.hash(crypto.Sha256, <<serialized:utf8>>)
}

/// Serialize event data to a JSON array string as defined in NIP-01.
/// Format: [0, pubkey, created_at, kind, tags, content]
fn serialize_for_id(
  pubkey: BitArray,
  created_at: Int,
  kind: Int,
  tags: List(List(String)),
  content: String,
) -> String {
  let pubkey_hex = bit_array.base16_encode(pubkey)

  json.array(
    [
      json.int(0),
      json.string(pubkey_hex),
      json.int(created_at),
      json.int(kind),
      json.array(tags, of: fn(t) { json.array(t, of: json.string) }),
      json.string(content),
    ],
    of: fn(x) { x },
  )
  |> json.to_string
}

/// Convert the event to a JSON object for transmission.
pub fn to_json(event: Event) -> Json {
  json.object([
    #("id", json.string(bit_array.base16_encode(event.id))),
    #("pubkey", json.string(bit_array.base16_encode(event.pubkey))),
    #("created_at", json.int(event.created_at)),
    #("kind", json.int(event.kind)),
    #(
      "tags",
      json.array(event.tags, of: fn(t) { json.array(t, of: json.string) }),
    ),
    #("content", json.string(event.content)),
    #("sig", json.string(bit_array.base16_encode(event.sig))),
  ])
}
