class AddMoneyToActivity < ActiveRecord::Migration
  def self.up
    Activity.transaction do
      Activity.all.each do |a|
        spend = a.spend || 0
        currency = a.currency
        currency = "USD" if currency.blank? #bad data, bad bad data.
        a.new_spend = build_money(a.id, spend, currency)
        budget = a.budget || 0
        a.new_budget = build_money(a.id, budget, currency)
        a.save(false)
      end
    end
  end

  def self.down
  end

  def self.build_money(id, amount, currency)
    pp "A: #{id}:  Amount: #{amount},  Currency: #{currency}"
    m = Money.new((amount*100).to_i, currency)
    pp "         New => #{m.to_s}, Currency: #{m.currency} (#{m.cents})"
    pp "WARN: conversion rounding difference" unless ("%.2f" % (amount || 0)) == m.to_s
    m
  end
end
