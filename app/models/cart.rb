class Cart < ActiveRecord::Base
  has_many :carts_events, :dependent => :destroy
  has_many :events, :through => :carts_events
  
  belongs_to :user
  
  serialize :paypal_params
  
  validates_presence_of :user_id
  validates_presence_of :status
  
  attr_protected :params, :status, :transaction_id, :purchased_at, :user_id
  
  before_validation_on_create :initialize_status
  
  STATUS = {
    :ON_SESSION       => 'On Session',
    :COMPLETED        => 'Completed'
  }
  
  named_scope :purchased, :conditions => [ 'purchased_at is not null' ]
  
  def paypal_url( return_url, notify_url )
    values = {
      :business   => 'seller_1231200230_biz@gmail.com',
      :cmd        => '_cart',
      :upload     => 1,
      :return     => return_url,
      :invoice    => self.id,
      :notify_url => notify_url
    }
    
    self.events.each_with_index do |event, index|
      values.merge!({
        "amount_#{index+1}"       => event.price_cents,
        "item_name_#{index+1}"    => event.name,
        "item_number_#{index+1}"  => event.id,
        "quantity_#{index+1}"     => 1
      })
    end
    
    "https://www.sandbox.paypal.com/cgi-bin/webscr?" + values.to_query
  end
  
  def total_price
    self.events.sum(:price_cents)
  end
  
  def self.retrieve_on_sesion_or_new( user_id )
    @cart = Cart.find( :first, :conditions => ["user_id = ? and status = ?", user_id, STATUS[:ON_SESSION]] )
    
    if @cart.nil?
      @cart = User.find( user_id ).carts.create!()
    end
    
    return @cart
  end
  
  def is_purchased?
    return !self.purchased_at.nil?
  end
  
  private
    def initialize_status
      self.status ||= STATUS[:ON_SESSION]
    end
end
