class BugsController < ApplicationController
  #  translate_js_to_fbjs
  def index
  end

  def new
    @bug = Bug.new
  end

  def create
    unless request.xhr?
      @bug = Bug.new(params[:bug])

      if @bug.save
        flash[:notice] = 'Bug was successfully logged.'
        redirect_to bugs_path
      else
        render :action => "new"
      end
      return
    end

    if(params[:format_type]=="fbml")
      @trans, @errors = translate_fbml(params[:code], params[:strict])
      @source = @trans
      render(:partial=>"translation") and return
    elsif(params[:format_type]=="js")
      begin
        @source = Js2Fbjs::FbjsRewriter.translate(params[:code], nil, params[:strict]) # js, tag, strict?
        @trans = "<script>#{@source}</script>"
      rescue
        @errors = "warning: translation failed for \"#{params[:code]}\" #{$!}"
      end
      render(:partial=>"translation") and return
    else
        #nothing
    end
  end
end
