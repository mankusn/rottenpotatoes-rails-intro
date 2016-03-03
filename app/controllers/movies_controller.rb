class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @movies = Movie.all
    @sort = params[:sort]
    @all_ratings = ['G','PG','PG-13','R'] 
    @ratings = params[:ratings]
    @selected_ratings = []
    @ratings_hash = {}
    
    if (!@sort && !@ratings &&(session[:sort]||session[:ratings]))
      redirect_to movies_path(:sort=>session[:sort], :ratings=>session[:ratings])
    end
    @all_ratings.each do |rate|
      if !@ratings
        if !session[:ratings]
          @ratings_hash[rate] = true
        elsif session[:ratings].has_key?(rate)
          @selected_ratings.push(rate)
          @ratings_hash[rate] = true 
        end 
      elsif @ratings.has_key?(rate)
        @selected_ratings.push(rate)
        @ratings_hash[rate] = true
        session[:ratings] = @ratings
        
      end
     end
     puts @ratings_hash
     
    if @sort
      session[:sort] = @sort
      if session[:ratings]
        @movies =Movie.all.order(session[:sort]).where(:rating => @ratings_hash.keys)
      elsif !session[:ratings]
        @movies = Movie.order(session[:sort])
        
      end
      
      if @sort == 'title'
        @title_header = 'hilite'
      elsif @sort == 'release_date'
        @release_header ='hilite'
      end
      
    elsif @ratings
      @movies = Movie.all.order(session[:sort]).where(:rating => @ratings_hash.keys)
      if session[:sort] == 'title'
        @title_header = 'hilite'
      elsif session[:sort] == 'release_date'
        @release_header ='hilite'
      end
    end   
    session[:ratings] = @ratings_hash    
  end
  
 
  
  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
