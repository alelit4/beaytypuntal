# encoding : utf-8
class CalendarsController < BeautifulController

  before_filter :load_calendar, :only => [:show, :edit, :update, :destroy]

  # Uncomment for check abilities with CanCan
  #authorize_resource

  def index
    session[:fields] ||= {}
    session[:fields][:calendar] ||= (Calendar.columns.map(&:name) - ["id"])[0..4]
    do_select_fields(:calendar)
    do_sort_and_paginate(:calendar)
    
    @q = Calendar.search(
      params[:q]
    )

    @calendar_scope = @q.result(
      :distinct => true
    ).sorting(
      params[:sorting]
    )
    
    @calendar_scope_for_scope = @calendar_scope.dup
    
    unless params[:scope].blank?
      @calendar_scope = @calendar_scope.send(params[:scope])
    end
    
    @calendars = @calendar_scope.paginate(
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
        render :json => @calendar_scope.all 
      }
      format.csv{
        require 'csv'
        csvstr = CSV.generate do |csv|
          csv << Calendar.attribute_names
          @calendar_scope.all.each{ |o|
            csv << Calendar.attribute_names.map{ |a| o[a] }
          }
        end 
        render :text => csvstr
      }
      format.xml{ 
        render :xml => @calendar_scope.all 
      }             
      format.pdf{
        pdfcontent = PdfReport.new.to_pdf(Calendar,@calendar_scope)
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
      format.json { render :json => @calendar }
    end
  end

  def new
    @calendar = Calendar.new

    respond_to do |format|
      format.html{
        if request.headers['X-PJAX']
          render :layout => false
        else
          render
        end
      }
      format.json { render :json => @calendar }
    end
  end

  def edit
    
  end

  def create
    @calendar = Calendar.create(params[:calendar])

    respond_to do |format|
      if @calendar.save
        format.html {
          if params[:mass_inserting] then
            redirect_to calendars_path(:mass_inserting => true)
          else
            redirect_to calendar_path(@calendar), :notice => t(:create_success, :model => "calendar")
          end
        }
        format.json { render :json => @calendar, :status => :created, :location => @calendar }
      else
        format.html {
          if params[:mass_inserting] then
            redirect_to calendars_path(:mass_inserting => true), :error => t(:error, "Error")
          else
            render :action => "new"
          end
        }
        format.json { render :json => @calendar.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update

    respond_to do |format|
      if @calendar.update_attributes(params[:calendar])
        format.html { redirect_to calendar_path(@calendar), :notice => t(:update_success, :model => "calendar") }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @calendar.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @calendar.destroy

    respond_to do |format|
      format.html { redirect_to calendars_url }
      format.json { head :ok }
    end
  end

  def batch
    attr_or_method, value = params[:actionprocess].split(".")

    @calendars = []    
    
    Calendar.transaction do
      if params[:checkallelt] == "all" then
        # Selected with filter and search
        do_sort_and_paginate(:calendar)

        @calendars = Calendar.search(
          params[:q]
        ).result(
          :distinct => true
        )
      else
        # Selected elements
        @calendars = Calendar.find(params[:ids].to_a)
      end

      @calendars.each{ |calendar|
        if not Calendar.columns_hash[attr_or_method].nil? and
               Calendar.columns_hash[attr_or_method].type == :boolean then
         calendar.update_attribute(attr_or_method, boolean(value))
         calendar.save
        else
          case attr_or_method
          # Set here your own batch processing
          # calendar.save
          when "destroy" then
            calendar.destroy
          end
        end
      }
    end
    
    redirect_to :back
  end

  def treeview

  end

  def treeview_update
    modelclass = Calendar
    foreignkey = :calendar_id

    render :nothing => true, :status => (update_treeview(modelclass, foreignkey) ? 200 : 500)
  end
  
  def demo
    @calendar = Calendar.all
    respond_to do |format|
      format.json { render :json => @calendar }
    end
  end
  
  def getallcalendars
    if(params[:competicion] != nil && params[:isla] != nil && params[:categoria] != nil && params[:jornada] != nil )
        @result = Calendar.where :competicion => params[:competicion], :isla => params[:isla], :categoria => params[:categoria], :jornada => params[:jornada]
        
    elsif(params[:competicion] != nil && params[:isla] != nil && params[:categoria] != nil )
        @result = Calendar.where :competicion => params[:competicion], :isla => params[:isla], :categoria => params[:categoria]
        
    else 
      @result = nil
    end
    respond_to do |format|
          format.json { render :json => @result }
    end
  end
  

  
  private 
  
  def load_calendar
    @calendar = Calendar.find(params[:id])
  end
end

