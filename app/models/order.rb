class Order < ApplicationRecord
  belongs_to :user
  belongs_to :giveback  
  has_one :payment
  has_one :project, through: :giveback
  before_create :build_trade_no
  acts_as_paranoid
  validates_presence_of :full_name, :delivery_country, :zip, :email, :message => ": 不可空白."
  validates :phone, format:{with: /\A09\d{8}\Z/,message:': 您的手機號碼需為10碼數字.'}

  enum status: [:order_received, :not_paid, :paid]

  def paid!
    self.issue_date = Time.now
    super
    project.reaching_goal
  end

  def self.to_csv
    attributes = %w{merchantOrderNo project_title giveback_title giveback_price issue_date status}

    CSV.generate(headers: true) do |csv|
      csv << attributes

      all.each do |order|
        csv << attributes.map{ |attr| order.send(attr) }
      end
    end
  end

  def self.to_csv_project
    order_attrs = %w{merchantOrderNo project_title giveback_title giveback_price full_name zip address phone email issue_date status}
    payment_attrs = %w[card_4no]
    all_attrs = [*order_attrs, *payment_attrs]
    
    CSV.generate(headers: true) do |csv|
      csv << all_attrs
      all.includes(:payment).each do |order|
        order_fields = order_attrs.map{|attr| order.send(attr)}
        payment_fields = payment_attrs.map{ |attr| order.payment&.send(attr) }
        csv << order_fields.concat(payment_fields)
      end
    end
  end


  def status_to_string
    case status_before_type_cast
    when Order.statuses[:order_received]
      return "訂單已成立，尚未付款"
    when Order.statuses[:not_paid]
      return "未付款"
    when Order.statuses[:paid]
      return "已付款"
    else
      return "狀態未明"
    end
  end

  private
    def build_trade_no
      self.merchantOrderNo = "CallBack#{user.id.to_i}#{Time.zone.now.to_i}"
    end
end
