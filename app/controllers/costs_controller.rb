class CostsController < ApplicationController
  def index
    @costs = current_user.costs.latest
  end

  def show
    @cost = Cost.find(params[:id])
  end

  def new
    @cost = Cost.new
  end

  def create
    @cost = current_user.costs.build(cost_params)
    if @cost.save
      flash[:notice] = "#{@cost.name}を登録しました"
      redirect_to costs_url
    else
      render :new
    end
  end

  def edit
    @cost = current_user.costs.find(params[:id])
  end

  def update
    @cost = current_user.costs.find(params[:id])
    if @cost.update!(cost_params)
      flash[:notice] = "#{@cost.name}を編集しました"
      redirect_to costs_url
    else
      render :edit
    end
  end

  def destroy
    @cost = current_user.costs.find(params[:id])
    @cost.destroy
    flash[:notice] = "#{@cost.name}を削除しました"
    redirect_to costs_url
  end

  def survey
    # 5/25/00:00~6/24/23:59は6月分として集計したい
    # costs/survey?year=2019&month=6
    begin
      @date = Time.zone.local(params[:year], params[:month])
    rescue
      return redirect_to root_path
    end
    # begin
    #   raw_date = Time.parse(params[:date])
    # rescue
    #   return redirect_to root_path
    # end
    # # 取り出した日がその月の25日以降か? 翌月 : 今月
    # @date = raw_date >= raw_date.beginning_of_month.advance(days: 24) ? raw_date.next_month : raw_date
    @costs = current_user.costs.period(@date)
    @total_cost = @costs.sum(:expenditure)
  end

  private

  def cost_params
    params.require(:cost).permit(
      :name,
      :expenditure,
      :paid_date,
      :demand
    )
  end
end
