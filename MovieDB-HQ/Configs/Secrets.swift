public enum Secrets {
  public enum Api {
    public enum Endpoint {
      public static let production = "api.themoviedb.org/3/movie"
      public static let staging = "api.themoviedb.org/3/movie"
      public static let local = "api.themoviedb.org/3/movie"
    }
    
    public enum Images {
      public static let production = "https://image.tmdb.org/t/p/w342"
    }
    
    public enum TMDB {
      public static let key = "b5c34c996b0f93d624c485c79881e04b"
    }

    public static let policy = ["api.themoviedb.org/": ServerTrustPolicy.disableEvaluation]
  }
}
