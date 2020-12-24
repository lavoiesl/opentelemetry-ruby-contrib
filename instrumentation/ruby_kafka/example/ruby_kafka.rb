# frozen_string_literal: true

# Copyright The OpenTelemetry Authors
#
# SPDX-License-Identifier: Apache-2.0

require 'rubygems'
require 'bundler/setup'

Bundler.require

require 'kafka'
require 'active_support'

span_processor = OpenTelemetry::SDK::Trace::Export::SimpleSpanProcessor.new(
  OpenTelemetry::SDK::Trace::Export::ConsoleSpanExporter.new
)

OpenTelemetry::SDK.configure do |c|
  c.use 'OpenTelemetry::Instrumentation::RubyKafka'
  c.add_span_processor(span_processor)
end

# Assumes kafka is available
kafka = Kafka.new(['kafka:9092', 'kafka:9092'], client_id: 'opentelemetry-ruby-demonstration')

# Instantiate a new producer.
producer = kafka.producer

# Add a message to the producer buffer.
producer.produce('hello example', topic: 'greetings')

# Deliver the messages to Kafka.
producer.deliver_messages

# Consume the message and break the loop
kafka.each_message(topic: 'greetings') do |message|
  puts message.offset, message.key, message.value
  break
end
