<!DOCTYPE html>
<html lang="zh-CN">

<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>阅后即焚</title>
<script src="https://cdn.tailwindcss.com"></script>
<script src="https://cdn.jsdelivr.net/npm/marked/marked.min.js"></script>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css"
integrity="sha512-9usAa10IRO0HhonpyAIVpjrylPvoDwiPUiKdWk5t3PyolY1cOd4DSEqGa+ri4AuTroPR5aQvXU9xC6qOPnzFeg=="
crossorigin="anonymous" referrerpolicy="no-referrer" />
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/katex@0.16.9/dist/katex.min.css" integrity="sha384-n8MVd4RsNIU0tAv4ct0nTaAbDJwPJzDEaqSD1odI+WdtXRGWt2kTvGFasHpSy3SV" crossorigin="anonymous">
<script src="https://cdn.jsdelivr.net/npm/katex@0.16.9/dist/katex.min.js" integrity="sha384-XjKyOOlGwcjNTAIQHIpgOno0Hl1YQqzUOEleOLALmuqehneUG+vnGctmUb0ZY0l8" crossorigin="anonymous"></script>
<script src="https://cdn.jsdelivr.net/npm/katex@0.16.9/dist/contrib/auto-render.min.js" integrity="sha384-+VBxd3r6XgURycqtZ117nYw44OOcIax56Z4dCRWbxyPt0Koah1uHoK0o4+/RRE05" crossorigin="anonymous"></script>

<!-- PhotoSwipe v5 -->
<link rel="stylesheet" href="https://unpkg.com/photoswipe@5/dist/photoswipe.css">
<script type="module" src="https://unpkg.com/photoswipe@5/dist/photoswipe-lightbox.esm.js"></script>

<?php
$envFile = parse_ini_file(__DIR__ . '/.env');
$encryptionKeyFromEnv = $envFile['ENCRYPTION_KEY'];
$siteIcon = $envFile['SITE_ICON'];
$siteDomain = $envFile['SITE_DOMAIN'];
$messageExpiry = isset($envFile['MESSAGE_EXPIRY']) ? $envFile['MESSAGE_EXPIRY'] : '7:0:0:0';

list($days, $hours, $minutes, $seconds) = array_pad(explode(':', $messageExpiry), 4, 0);
$expirySeconds = ($days * 24 * 60 * 60) + ($hours * 60 * 60) + ($minutes * 60) + $seconds;

if (!empty($siteIcon)) {
  if (str_starts_with($siteIcon, 'data:image')) {
    echo '<link rel="icon" href="' . htmlspecialchars($siteIcon) . '">';
  } else {
    echo '<link rel="icon" href="' . htmlspecialchars($siteIcon) . '" type="image/x-icon">';
  }
}
?>

<style>
/* 你原有的所有 style 內容保持不變，這裡省略以縮短回應長度 */
.message-box { ... }
/* ... 其他原有樣式 ... */
.content-box.markdown-mode #displayContent img {
  cursor: zoom-in;
  max-width: 100%;
  height: auto;
  border-radius: 4px;
}
</style>
</head>

<body class="bg-gradient-to-r from-blue-100 to-blue-300 font-sans min-h-screen flex items-center justify-center">

<div class="container mx-auto p-8">

<?php
// 你原有的 PHP 邏輯保持不變，這裡只展示查看消息的部分修改點

// ... 中間的 PHP 邏輯（加密、解密、檔案處理等） ...

if (isset($_GET['file']) && isset($_GET['code'])) {
  // ... 原有邏輯 ...

  if (hashVerificationCode($verificationCode) === $messageData['hashedVerificationCode']) {
    if (isset($_GET['confirm'])) {
      // ... 解密成功後顯示內容 ...

      echo '<div class="message-box mb-6 viewing-message">';

      // 發件人資訊
      if (!empty($decryptedSenderName) || !empty($decryptedSenderNote)) { ?>
        <div class="sender-info">
          <i class="fas fa-user"></i>
          <span>
            <?php echo empty($decryptedSenderName) ? '无发件人' : htmlspecialchars($decryptedSenderName); ?>
            (<?php echo empty($decryptedSenderNote) ? '无备注' : htmlspecialchars($decryptedSenderNote); ?>)
          </span>
        </div>
      <?php } else { ?>
        <div class="sender-info">
          <i class="fas fa-user"></i>
          <span>无发件人（无备注）</span>
        </div>
      <?php } ?>

      <div class="content-box-wrapper">
        <div class="options-container mb-4">
          <label class="option-item" id="markdownLabel">
            <input type="checkbox" id="markdownCheckbox" onchange="toggleMarkdown(this)">
            <span>渲染 Markdown</span>
          </label>
          <label class="option-item" id="heightLabel">
            <input type="checkbox" id="autoHeightCheckbox" onchange="toggleHeight(this)">
            <span>自适应高度</span>
          </label>
        </div>

        <div class="content-box mb-6" id="message-text">
          <div id="rawContent" style="display:none"><?php echo htmlspecialchars($decryptedMessage); ?></div>
          <div id="displayContent"><?php echo htmlspecialchars($decryptedMessage); ?></div>
        </div>

        <button class="copy-button" onclick="copyMessage()">
          <i class="fas fa-copy"></i>
          <span></span>
        </button>
      </div>

      <?php
      echo '</div>';
    } else {
      // ... 確認查看或輸入密碼的邏輯保持不變 ...
    }
  } else {
    // ... 驗證失敗 ...
  }
} else {
  // ... 發送消息表單部分保持不變 ...
}
?>

</div>

<!-- PhotoSwipe 容器（必須放在 body 最後） -->
<div class="pswp" tabindex="-1" role="dialog" aria-hidden="true">
  <div class="pswp__bg"></div>
  <div class="pswp__scroll-wrap">
    <div class="pswp__container">
      <div class="pswp__item"></div>
      <div class="pswp__item"></div>
      <div class="pswp__item"></div>
    </div>
    <div class="pswp__ui pswp__ui--hidden">
      <div class="pswp__top-bar">
        <div class="pswp__counter"></div>
        <button class="pswp__button pswp__button--close" title="关闭（Esc）" aria-label="Close"></button>
        <button class="pswp__button pswp__button--share" title="分享" aria-label="Share"></button>
        <button class="pswp__button pswp__button--fs" title="切换全屏" aria-label="Toggle fullscreen"></button>
        <button class="pswp__button pswp__button--zoom" title="缩放" aria-label="Zoom"></button>
      </div>
      <button class="pswp__button pswp__button--arrow--left" title="上一张" aria-label="Previous"></button>
      <button class="pswp__button pswp__button--arrow--right" title="下一张" aria-label="Next"></button>
      <div class="pswp__caption">
        <div class="pswp__caption__center"></div>
      </div>
    </div>
  </div>
</div>

<script>
// 你原有的 copyToClipboard、toggleHeight 等函數保持不變，這裡只新增/修改與 PhotoSwipe 相關的部分

// 初始化 PhotoSwipe 的函數
function initPhotoSwipe() {
  const displayContent = document.getElementById('displayContent');
  if (!displayContent) return;

  // 為圖片加上視覺提示
  displayContent.querySelectorAll('img').forEach(img => {
    img.style.cursor = 'zoom-in';
    if (!img.hasAttribute('loading')) {
      img.setAttribute('loading', 'lazy');
    }
  });

  // 點擊事件（使用事件委託）
  displayContent.addEventListener('click', function(e) {
    const img = e.target.closest('img');
    if (!img) return;

    e.preventDefault();
    e.stopPropagation();

    const allImages = Array.from(displayContent.querySelectorAll('img'));
    const clickedIndex = allImages.indexOf(img);

    if (clickedIndex === -1) return;

    const items = allImages.map(image => {
      let src = image.currentSrc || image.src;
      if (image.dataset.src) src = image.dataset.src;
      if (image.dataset.large) src = image.dataset.large;

      return {
        src,
        w: image.naturalWidth || image.width * 2 || 1600,
        h: image.naturalHeight || image.height * 2 || 1200,
        msrc: image.src,
        title: image.alt || image.title || '图片预览'
      };
    });

    // 動態導入 PhotoSwipe（減少初始載入）
    import('https://unpkg.com/photoswipe@5/dist/photoswipe.esm.js')
      .then(({ default: PhotoSwipe }) => {
        const lightbox = new window.PhotoSwipeLightbox({
          gallery: '#displayContent',
          children: 'img',
          pswpModule: PhotoSwipe,
          initialZoomLevel: 'fit',
          secondaryZoomLevel: 2.5,
          maxZoomLevel: 4,
          bgOpacity: 0.9,
          index: clickedIndex,
          preload: [1, 2],
          closeTitle: '关闭',
          zoomTitle: '缩放',
          arrowPrevTitle: '上一张',
          arrowNextTitle: '下一张',
          errorMsg: '图片加载失败',
          caption: (slide) => slide.data.title || ''
        });

        lightbox.on('share', () => {
          const current = lightbox.pswp.currSlide;
          if (current && current.data.src && navigator.share) {
            navigator.share({
              title: current.data.title || '分享图片',
              url: current.data.src
            }).catch(() => {});
          }
        });

        lightbox.init();
        lightbox.loadAndOpen(clickedIndex);
      })
      .catch(err => {
        console.error('PhotoSwipe 加载失败:', err);
        window.open(items[clickedIndex].src, '_blank');
      });
  });
}

function toggleMarkdown(checkbox) {
  const messageText = document.getElementById('message-text');
  const rawContent = document.getElementById('rawContent');
  const displayContent = document.getElementById('displayContent');
  const markdownLabel = document.getElementById('markdownLabel');

  if (checkbox.checked) {
    markdownLabel.classList.add('active');
    messageText.classList.add('markdown-mode');

    const renderer = new marked.Renderer();
    marked.setOptions({
      renderer: renderer,
      breaks: true,
      gfm: true,
      headerIds: false
    });

    displayContent.innerHTML = marked.parse(rawContent.textContent);

    renderMathInElement(displayContent, {
      delimiters: [
        {left: "$$", right: "$$", display: true},
        {left: "$", right: "$", display: false},
        {left: "\\[", right: "\\]", display: true},
        {left: "\\(", right: "\\)", display: false}
      ],
      throwOnError: false,
      output: "html"
    });

    // 渲染完成後初始化 PhotoSwipe
    setTimeout(initPhotoSwipe, 100);
  } else {
    markdownLabel.classList.remove('active');
    messageText.classList.remove('markdown-mode');
    displayContent.textContent = rawContent.textContent;
  }
}

// 頁面載入時也嘗試初始化（以防萬一）
document.addEventListener('DOMContentLoaded', () => {
  setTimeout(initPhotoSwipe, 300);
});

// 你原有的其他函數（copyMessage、toggleHeight、copyToClipboard 等）保持不變
function copyMessage() { /* 原有代碼 */ }
function toggleHeight(checkbox) { /* 原有代碼 */ }
// ... 其他原有 JS ...
</script>

</body>
</html>