//
//  VideoTableViewCell.swift
//  Sojumap
//
//  Created by Macbook on 2023/09/08.
//

import UIKit

class VideoTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var videoImage: UIImageView!
    @IBOutlet weak var videoTitle: UILabel!
    @IBOutlet weak var videoInfo: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    
    
    var imageUrl: String? {
        didSet {
            loadImage()
        }
    }
    
    private func loadImage() {
        guard let urlString = self.imageUrl else { return }
        guard let url = URL(string: urlString)  else { return }

        DispatchQueue.global().async {
            guard let data = try? Data(contentsOf: url) else { return }
            guard self.imageUrl == url.absoluteString else { return }

            DispatchQueue.main.async {
                self.videoImage.image = UIImage(data: data)
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.videoImage.image = nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        videoImage.contentMode = .scaleToFill
        self.videoImage.clipsToBounds = true
        self.videoImage.layer.cornerRadius = 7
        self.saveButton.setImage(UIImage(systemName: "wineglass"), for: .normal)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
