class Donation

  MONTHLY_GOAL = 250.00

  def self.monthly_statistics

    begins = DateTime.now.beginning_of_month
    deadline  = DateTime.now.end_of_month

    amount = PaymentNotification.where(
      :created_at.gt => begins,
      :created_at.lt => deadline
    ).sum(:amount)

    count = PaymentNotification.where(
      :created_at.gt => begins,
      :created_at.lt => deadline
    ).count

    percent = amount < MONTHLY_GOAL ? amount.percent_of(MONTHLY_GOAL) : 100.0

    statistics = OpenStruct.new(
      begins:     begins,
      deadline:   deadline,
      amount:     amount,
      goal:       MONTHLY_GOAL,
      complete:   percent.round(1),
      supporters: count
    )

    return statistics

  end

  def self.paypal_donate_url_for(user)

    if Rails.env.development?
      business = 'seller_1362637130_biz@vallin.se'
      url_base = "https://www.sandbox.paypal.com/cgi-bin/webscr?"
      notify_url = "http://requestb.in/1kjevtc1"
      return_url = "http://local.cloudsdale.org:3000/"
    else
      business = 'ask@cloudsdale.org'
      url_base = "https://www.paypal.com/cgi-bin/webscr?"
      notify_url = "http://www.cloudsdale.org/donations/paypal_ipn"
      return_url = "http://www.cloudsdale.org/"
    end

    vals = {
      :business     => business,
      :cmd          => '_donations',
      :return       => return_url,
      :notify_url   => notify_url,
      :item_name    => 'Cloudsdale Server Donation',
      :item_number  => 'donation',
      :custom       => user.id }

    url_base + vals.to_query

  end

end
