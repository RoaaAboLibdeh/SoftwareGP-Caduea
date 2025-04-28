const multer = require('multer');
const path = require('path');

// إعداد تخزين الملفات
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, 'uploads/'); // احفظها في مجلد اسمه uploads
  },
  filename: function (req, file, cb) {
    const uniqueName = Date.now() + '-' + file.originalname;
    cb(null, uniqueName);
  }
});

// تأكيد إن الملف صورة
const fileFilter = (req, file, cb) => {
  const allowedTypes = /jpeg|jpg|png|gif/;

  const extName = path.extname(file.originalname).toLowerCase();
  const mimeType = file.mimetype;

  const isExtValid = allowedTypes.test(extName);
  const isMimeValid = allowedTypes.test(mimeType);

  console.log(`🧐 File received: ${file.originalname}`);
  console.log(`📂 Extension: ${extName}, 🧾 Mime: ${mimeType}`);

  if (isExtValid && isMimeValid) {
    cb(null, true);
  } else {
    console.warn(`🚫 Rejected file: ${file.originalname} (mime: ${mimeType}, ext: ${extName})`);
    cb(new Error('Only image files are allowed!'), false);
  }
};

const upload = multer({ storage: storage, fileFilter: fileFilter });

module.exports = upload;
