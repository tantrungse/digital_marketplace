module Api
  module V1
    module Buyer
      class SpendController < ApplicationController
        def index
          buyer_id = params[:buyer_id] || current_user&.id
          kind = params[:kind] || 'monthly'
          from = params[:from]
          to = params[:to]
          tag_id = params[:tag_id]
          category_id = params[:category_id]

          model, date_field = case kind
          when 'daily'
            [BuyerDailySpend, :spend_date]
          when 'weekly'
            [BuyerWeeklySpend, :week_start]
          when 'monthly'
            [BuyerMonthlySpend, :month]
          when 'yearly'
            [BuyerYearlySpend, :year_start]
          else
            render json: { error: "Invalid kind" }, status: :bad_request and return
          end

          records = model.where(buyer_id: buyer_id)
          records = records.where("#{date_field} >= ?", from) if from
          records = records.where("#{date_field} <= ?", to) if to
          records = records.where(tag_id: tag_id) if tag_id.present?
          records = records.where(category_id: category_id) if category_id.present?
          records = records.order(date_field)
          grouped = records.group(date_field).sum(:total_spent)

          results = grouped.map do |date, amount|
            {
              label: date,
              total_spent: amount.to_f
            }
          end

          render json: results
        end
      end
    end
  end
end
