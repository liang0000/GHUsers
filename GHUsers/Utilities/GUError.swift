//


import Foundation

enum GUError: String, Error {
	case invalidUsername 		= "This username created an invalid request. Please try again."
	case unableToComplete 		= "Unable to complete your request. Please check your internet connection."
	case invalidResponse 		= "Invalid response from the server. Please try again."
	case invalidData 			= "The data received from the server was invalid. Please try again."
	case invalidURL 			= "There is an error trying to reach the server. If this persists, please contact support."
	case unableToSaveUsers 		= "There was an error saving users. Please try again."
	case unableToLoadUsers 		= "There was an error loading users. Please try again."
	case unableToSaveUserInfo 	= "There was an error saving this user info. Please try again."
	case unableToLoadUserInfo	= "There was an error loading this user info. Please try again."
}
