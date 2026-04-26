export default function AvatarBadge({
  avatar,
  initials,
  size = 'md',
  className = '',
  textClassName = '',
  alt = 'Avatar',
}) {
  const sizeMap = {
    sm: 'h-10 w-10 text-sm',
    md: 'h-12 w-12 text-sm',
    lg: 'h-24 w-24 text-xl',
  }

  const sizeClass = sizeMap[size] || sizeMap.md

  if (avatar) {
    return (
      <span
        className={`inline-flex ${sizeClass} overflow-hidden border border-cyan-300/60 bg-cyan-300/10 ${className}`}
      >
        <img src={avatar} alt={alt} className="h-full w-full object-cover" />
      </span>
    )
  }

  return (
    <span
      className={`inline-flex ${sizeClass} items-center justify-center border border-cyan-300/60 bg-cyan-300/10 font-black tracking-[0.24em] text-cyan-100 ${className} ${textClassName}`}
    >
      {initials}
    </span>
  )
}
