resource "aws_dynamodb_table" "word_map" {
  name         = "word_map"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "word"

  attribute {
    name = "word"
    type = "S"
  }

  point_in_time_recovery {
    enabled = false
  }
}

resource "aws_dynamodb_table_item" "items" {
  for_each = local.replace_words

  table_name = aws_dynamodb_table.word_map.name
  hash_key   = aws_dynamodb_table.word_map.hash_key

  item = <<ITEM
{
  "word": {"S": "${each.key}"},
  "mapped_word": {"S": "${each.value}"}
}
ITEM
}
