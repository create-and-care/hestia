class SavingsEnvelopesController < ApplicationController
  def create
    Current.household.savings_envelopes.create(envelope_params)
    redirect_to budget_path
  end

  def destroy
    Current.household.savings_envelopes.find(params[:id]).destroy
    redirect_to budget_path, notice: t(".deleted")
  end

  private
    def envelope_params
      params.require(:savings_envelope).permit(:name, :recurring_deposit)
    end
end
