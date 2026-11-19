class CancelUnpaidOrdersJob < ApplicationJob
  queue_as :default

  def perform
    Order.stale_unpaid.find_each(&:cancel_if_unpaid!)
  end
end
