import Foundation

struct Series : Identifiable {
    var id = UUID()
    let name: String
    let added: Int
    let network: String
    let lastFound: Date
    
    var episodes: [Programme] = []
}
