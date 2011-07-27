(require 'android-defs)

;; adapted from nehe opengl lesson 5

(define (log str)
  (<android.util.Log>:d "SchemeOGL" str))

(define-alias gl-surface-view android.opengl.GLSurfaceView)
(define-alias gl10 javax.microedition.khronos.opengles.GL10)
(define-alias egl-config javax.microedition.khronos.egl.EGLConfig)
(define-alias float-buffer java.nio.FloatBuffer)
(define-alias byte-buffer java.nio.ByteBuffer)
(define-alias short-buffer java.nio.ShortBuffer)
(define-alias byte-order java.nio.ByteOrder)
(define-alias motion-event android.view.MotionEvent)
(define-alias renderer android.opengl.GLSurfaceView$Renderer)
(define-alias glu android.opengl.GLU)

(define-simple-class Cube ()
  (vertexBuffer :: float-buffer)
  (colorBuffer :: float-buffer)
  (indexBuffer :: byte-buffer)
  ((*init*)
   (let* ((vertices (float[] -1.0 -1.0 -1.0
                         1.0 -1.0 -1.0
                         1.0  1.0 -1.0
                         -1.0 1.0 -1.0
                         -1.0 -1.0  1.0
                         1.0 -1.0  1.0
                         1.0  1.0  1.0
                         -1.0  1.0  1.0))
          (colors (float[] 0.0  1.0  0.0  1.0
                       0.0  1.0  0.0  1.0
                       1.0  0.5  0.0  1.0
                       1.0  0.5  0.0  1.0
                       1.0  0.0  0.0  1.0
                       1.0  0.0  0.0  1.0
                       0.0  0.0  1.0  1.0
                       1.0  0.0  1.0  1.0))
         (indices (byte[] 0 4 5    0 5 1
                        1 5 6    1 6 2
                        2 6 7    2 7 3
                        3 7 4    3 4 0
                        4 7 6    4 6 5
                        3 0 1    3 1 2))
         (byteBuf :: byte-buffer (byte-buffer:allocateDirect (* vertices:length 4))))
     (byteBuf:order (byte-order:nativeOrder))
     (set! vertexBuffer (byteBuf:asFloatBuffer))
     (vertexBuffer:put vertices)
     (vertexBuffer:position 0)

     (set! byteBuf (byte-buffer:allocateDirect (* colors:length 4)))
     (byteBuf:order (byte-order:nativeOrder))
     (set! colorBuffer (byteBuf:asFloatBuffer))
     (colorBuffer:put colors)
     (colorBuffer:position 0)

     (set! indexBuffer (byte-buffer:allocateDirect indices:length))
     (indexBuffer:put indices)
     (indexBuffer:position 0)))
  ((draw (gl :: gl10)) :: void
   (gl:glFrontFace gl10:GL_CW)
   (gl:glVertexPointer 3 gl10:GL_FLOAT 0 vertexBuffer)
   (gl:glColorPointer 4 gl10:GL_FLOAT 0 colorBuffer)
   (gl:glEnableClientState gl10:GL_VERTEX_ARRAY)
   (gl:glEnableClientState gl10:GL_COLOR_ARRAY)
   (gl:glDrawElements gl10:GL_TRIANGLES 36 gl10:GL_UNSIGNED_BYTE indexBuffer)
   (gl:glDisableClientState gl10:GL_VERTEX_ARRAY)
   (gl:glDisableClientState gl10:GL_COLOR_ARRAY)))

(define-simple-class Pyramid ()
  (vertexBuffer :: float-buffer)
  (colorBuffer :: float-buffer)
  (num-vertices-third :: int)
  ((*init*)
   (let* ((vertices (float[]
                          0.0  1.0  0.0 ; top
                          -1.0 -1.0 1.0 ; left front
                          1.0 -1.0 1.0 ; right front
                          0.0  1.0 0.0
                          1.0 -1.0 1.0
                          1.0 -1.0 -1.0 ; right back
                          0.0  1.0 0.0
                          1.0 -1.0 -1.0
                          -1.0 -1.0 -1.0 ; left back
                          0.0  1.0 0.0
                          -1.0 -1.0 -1.0
                          -1.0 -1.0 1.0
                          -1.0 -1.0 1.0 ; bottom
                          1.0 -1.0 1.0
                          -1.0 -1.0 -1.0
                          -1.0 -1.0 -1.0
                          1.0 -1.0 1.0
                          1.0 -1.0 -1.0
                          ))
         (colors (float[] 1.0 0.0 0.0 1.0
                        0.0 1.0 0.0 1.0
                        0.0 0.0 1.0 1.0
                        1.0 0.0 0.0 1.0
                        0.0 0.0 1.0 1.0
                        0.0 1.0 0.0 1.0
                        1.0 0.0 0.0 1.0
                        0.0 1.0 0.0 1.0
                        0.0 0.0 1.0 1.0
                        1.0 0.0 0.0 1.0
                        0.0 0.0 1.0 1.0
                        0.0 1.0 0.0 1.0
                        ;; bottom
                        0.0 1.0 0.0 1.0
                        0.0 0.0 1.0 1.0
                        0.0 0.0 1.0 1.0
                        0.0 0.0 1.0 1.0
                        0.0 0.0 1.0 1.0
                        0.0 1.0 0.0 1.0

                        ))
         (byteBuf :: byte-buffer (byte-buffer:allocateDirect (* vertices:length 4))))
     (set! num-vertices-third (as int (/ vertices:length 3)))

     (byteBuf:order (byte-order:nativeOrder))
     (set! vertexBuffer (byteBuf:asFloatBuffer))
     (vertexBuffer:put vertices)
     (vertexBuffer:position 0)

     (set! byteBuf (byte-buffer:allocateDirect (* colors:length 4)))
     (byteBuf:order (byte-order:nativeOrder))
     (set! colorBuffer (byteBuf:asFloatBuffer))
     (colorBuffer:put colors)
     (colorBuffer:position 0)))
  ((draw (gl :: gl10)) :: void
   (gl:glFrontFace gl10:GL_CW)
   (gl:glVertexPointer 3 gl10:GL_FLOAT 0 vertexBuffer)
   (gl:glColorPointer 4 gl10:GL_FLOAT 0 colorBuffer)
   (gl:glEnableClientState gl10:GL_VERTEX_ARRAY)
   (gl:glEnableClientState gl10:GL_COLOR_ARRAY)
   (gl:glDrawArrays gl10:GL_TRIANGLES 0 num-vertices-third)
   (gl:glDisableClientState gl10:GL_VERTEX_ARRAY)
   (gl:glDisableClientState gl10:GL_COLOR_ARRAY)))

(define-simple-class lesson-05 (renderer)
  (pyramid :: Pyramid)
  (pyramid2 :: Pyramid)
  (cube :: Cube)
  (cube2 :: Cube)
  (rtri :: float)
  (rtri2 :: float)
  (rquad :: float)
  (rquad2 :: float)
  (current-frame-count-start :: int)
  (frame-count :: int)
  (last-draw :: int)
  ((*init*)
   (set! pyramid (Pyramid))
   (set! pyramid2 (Pyramid))
   (set! cube (Cube))
   (set! cube2 (Cube))
   (set! last-draw (<java.lang.System>:currentTimeMillis))
   (set! current-frame-count-start last-draw))
  ((onSurfaceCreated (gl :: gl10) (config :: egl-config)) :: void
   (gl:glShadeModel gl10:GL_SMOOTH)
   (gl:glClearColor 0.0 0.0 0.0 0.5)
   (gl:glClearDepthf 1.0)
   (gl:glEnable gl10:GL_DEPTH_TEST)
   (gl:glDepthFunc gl10:GL_LEQUAL)
   (gl:glHint gl10:GL_PERSPECTIVE_CORRECTION_HINT gl10:GL_NICEST))
  ((onDrawFrame (gl :: gl10)) :: void
       ;; (let ((now :: int (<java.lang.System>:currentTimeMillis)))
       ;;   (if (>= (- now current-frame-count-start) 1000)
       ;;       (begin
       ;;         (log (format "~A fps" frame-count))
       ;;         (set! current-frame-count-start now)
       ;;         (set! frame-count 1))
       ;;       (set! frame-count (+ 1 frame-count)))

       ;;   (set! delta (/ (- now last-draw) 1000))
       ;;   (set! last-draw now))
   (gl:glClear (bitwise-ior gl10:GL_COLOR_BUFFER_BIT gl10:GL_DEPTH_BUFFER_BIT))
   (gl:glLoadIdentity)
   (gl:glTranslatef 0.8 -1.0 -7.0)
   (gl:glScalef 0.5 0.5 0.5)
   (gl:glRotatef rquad 0.0 1.0 1.0)
   (cube:draw gl)
   (gl:glLoadIdentity)
   (gl:glTranslatef -0.8 1.0 -7.0)
   (gl:glScalef 0.5 0.5 0.5)
   (gl:glRotatef rquad2 1.0 0.0 1.0)
   (cube2:draw gl)
   (gl:glLoadIdentity)
   (gl:glTranslatef 0.8 1.0 -6.0)
   (gl:glScalef 0.5 0.5 0.5)
   (gl:glRotatef rtri 0.3 1.0 0.0)
   (pyramid:draw gl)
   (gl:glLoadIdentity)
   (gl:glTranslatef -0.8 -1.0 -6.0)
   (gl:glScalef 0.5 0.5 0.5)
   (gl:glRotatef rtri2 0.0 0.9 0.3)
   (pyramid2:draw gl)

   (set! rtri (+ rtri 1))
   (set! rquad (- rquad 0.65))
   (set! rtri2 (- rtri2 0.8))
   (set! rquad2 (+ rquad2 0.75)))
  ((onSurfaceChanged (gl :: gl10) (width :: int) (height :: int)) :: void
   (set! height (if (= height 0) 1 height))
   (gl:glViewport 0 0 width height)
   (gl:glMatrixMode gl10:GL_PROJECTION)
   (gl:glLoadIdentity)
   (glu:gluPerspective gl 45 (/ (as float width) (as float height)) 0.1 100.0)
   (gl:glMatrixMode gl10:GL_MODELVIEW)
   (gl:glLoadIdentity)))

;; main activity
(activity at.nexoid.schemeogl.SchemeOGL
          (gl-surface :: gl-surface-view)
          (on-create
           (set! gl-surface (gl-surface-view (this)))
           (gl-surface:setRenderer (lesson-05))
           (setContentView gl-surface)
           gl-surface)
          ((onResume) :: void
           (invoke-special <android.app.Activity> (this) 'onResume)
           (gl-surface:onResume))
          ((onPause) :: void
           (invoke-special <android.app.Activity> (this) 'on-pause)
           (gl-surface:on-pause)))

;; Local Variables:
;; compile-command: "cd .. && ./make debug && ./make install"
;; End:
