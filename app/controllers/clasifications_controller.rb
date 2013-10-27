# encoding : utf-8
class ClasificationsController < BeautifulController

  before_filter :load_clasification, :only => [:show, :edit, :update, :destroy]

  # Uncomment for check abilities with CanCan
  #authorize_resource

  def index
    session[:fields] ||= {}
    session[:fields][:clasification] ||= (Clasification.columns.map(&:name) - ["id"])[0..4]
    do_select_fields(:clasification)
    do_sort_and_paginate(:clasification)
    
    @q = Clasification.search(
      params[:q]
    )

    @clasification_scope = @q.result(
      :distinct => true
    ).sorting(
      params[:sorting]
    )
    
    @clasification_scope_for_scope = @clasification_scope.dup
    
    unless params[:scope].blank?
      @clasification_scope = @clasification_scope.send(params[:scope])
    end
    
    @clasifications = @clasification_scope.paginate(
      :page => params[:page],
      :per_page => 20
    ).all

    respond_to do |format|
      format.html{
        if request.headers['X-PJAX']
          render :layout => false
        else
          render
        end
      }
      format.json{
        render :json => @clasification_scope.all 
      }
      format.csv{
        require 'csv'
        csvstr = CSV.generate do |csv|
          csv << Clasification.attribute_names
          @clasification_scope.all.each{ |o|
            csv << Clasification.attribute_names.map{ |a| o[a] }
          }
        end 
        render :text => csvstr
      }
      format.xml{ 
        render :xml => @clasification_scope.all 
      }             
      format.pdf{
        pdfcontent = PdfReport.new.to_pdf(Clasification,@clasification_scope)
        send_data pdfcontent
      }
    end
  end

  def show
    respond_to do |format|
      format.html{
        if request.headers['X-PJAX']
          render :layout => false
        else
          render
        end
      }
      format.json { render :json => @clasification }
    end
  end

  def new
    @clasification = Clasification.new

    respond_to do |format|
      format.html{
        if request.headers['X-PJAX']
          render :layout => false
        else
          render
        end
      }
      format.json { render :json => @clasification }
    end
  end

  def edit
    
  end

  def create
    @clasification = Clasification.create(params[:clasification])

    respond_to do |format|
      if @clasification.save
        format.html {
          if params[:mass_inserting] then
            redirect_to clasifications_path(:mass_inserting => true)
          else
            redirect_to clasification_path(@clasification), :notice => t(:create_success, :model => "clasification")
          end
        }
        format.json { render :json => @clasification, :status => :created, :location => @clasification }
      else
        format.html {
          if params[:mass_inserting] then
            redirect_to clasifications_path(:mass_inserting => true), :error => t(:error, "Error")
          else
            render :action => "new"
          end
        }
        format.json { render :json => @clasification.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update

    respond_to do |format|
      if @clasification.update_attributes(params[:clasification])
        format.html { redirect_to clasification_path(@clasification), :notice => t(:update_success, :model => "clasification") }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @clasification.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @clasification.destroy

    respond_to do |format|
      format.html { redirect_to clasifications_url }
      format.json { head :ok }
    end
  end

  def batch
    attr_or_method, value = params[:actionprocess].split(".")

    @clasifications = []    
    
    Clasification.transaction do
      if params[:checkallelt] == "all" then
        # Selected with filter and search
        do_sort_and_paginate(:clasification)

        @clasifications = Clasification.search(
          params[:q]
        ).result(
          :distinct => true
        )
      else
        # Selected elements
        @clasifications = Clasification.find(params[:ids].to_a)
      end

      @clasifications.each{ |clasification|
        if not Clasification.columns_hash[attr_or_method].nil? and
               Clasification.columns_hash[attr_or_method].type == :boolean then
         clasification.update_attribute(attr_or_method, boolean(value))
         clasification.save
        else
          case attr_or_method
          # Set here your own batch processing
          # clasification.save
          when "destroy" then
            clasification.destroy
          end
        end
      }
    end
    
    redirect_to :back
  end

  def treeview

  end

  def treeview_update
    modelclass = Clasification
    foreignkey = :clasification_id

    render :nothing => true, :status => (update_treeview(modelclass, foreignkey) ? 200 : 500)
  end
  
  def getclasification
    if(params[:competicion] != nil && params[:isla] != nil && params[:categoria] != nil )
        @result = Clasification.where :competicion => params[:competicion], :isla => params[:isla], :categoria => params[:categoria]
        
    elsif(params[:competicion] != nil && params[:isla] != nil )
        @result = Clasification.where :competicion => params[:competicion], :isla => params[:isla]
        
    else 
      @result = nil
    end
    respond_to do |format|
          format.json { render :json => @result }
    end
  end
  
  
  private 
  
  def load_clasification
    @clasification = Clasification.find(params[:id])
  end
end

