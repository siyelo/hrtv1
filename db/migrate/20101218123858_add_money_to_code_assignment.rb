class AddMoneyToCodeAssignment < ActiveRecord::Migration
  def self.up
    CodeAssignment.transaction do
      CodeAssignment.all.each do |a|
        amount = a.amount || 0
        cached_amount = a.cached_amount || 0
        currency = ""
        currency = a.activity.currency unless a.activity.nil?
        currency = "USD" if currency.blank? #bad data, bad bad data.
        a.new_amount = build_money(a.id, amount, currency, 'amount')
        a.new_cached_amount = build_money(a.id, cached_amount, currency, 'cached_amount')
        a.save(false)
      end
    end
  end

  def self.down
  end

  def self.build_money(id, amount, currency, field_name)
    #puts "."
    pp "CA #{id}:  #{field_name}: #{amount},  Currency: #{currency}"
    m = Money.new((amount*100).to_i, currency)
    pp "         New => #{m.to_s}, Currency: #{m.currency} (#{m.cents})"
    pp "WARN: conversion rounding difference" unless ("%.2f" % (amount || 0)) == m.to_s
    m
  end
end
