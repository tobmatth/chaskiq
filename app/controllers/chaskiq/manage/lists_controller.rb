require_dependency "chaskiq/application_controller"

module Chaskiq
  class Manage::ListsController < ApplicationController

    before_filter :authentication_method

    def index
      @q = Chaskiq::List.ransack(params[:q])
      @lists = @q.result
      .page(params[:page])
      .per(8)
    end

    def show
      @list =  Chaskiq::List.find(params[:id])
      @subscribers = @list.subscribers.page(params[:page]).per(50)
    end

    def new
      @list =  Chaskiq::List.new
    end

    def edit
      @list =  Chaskiq::List.find(params[:id])
    end

    def upload
      @list =  Chaskiq::List.find(params[:id])

      if path = params[:list][:upload_file].try(:tempfile)
        Chaskiq::ListImporterJob.perform_later(@list, params[:list][:upload_file].tempfile.path)
        flash[:notice] = "We are importing in background, refresh after a while ;)"
      else
        flash[:error] = "Whoops!"
      end

      redirect_to manage_list_path(@list)
    end

    def clear
      @list =  Chaskiq::List.find(params[:id])
      @list.subscriptions.delete_all
      flash[:notice] = "We are importing in background, refresh after a while ;)"

      redirect_to manage_list_path(@list)
    end

    def update
      @list =  Chaskiq::List.find(params[:id])
      if @list.update_attributes(resource_params)
        redirect_to manage_lists_path
      else
        render "new"
      end
    end

    def create
      if @list =  Chaskiq::List.create(resource_params)
        redirect_to manage_lists_path
      else
        render "new"
      end
    end

    def destroy
      @list =  Chaskiq::List.find(params[:id])
      if @list.destroy
        flash[:notice] = "Destroyed succesfully"
        redirect_to manage_lists_path
      end
    end

  protected

    def resource_params
      return [] if request.get?
      params.require(:list).permit! #(:name)
    end

  end
end
