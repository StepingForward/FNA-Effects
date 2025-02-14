using System;
using System.Diagnostics;
using System.Diagnostics.Tracing;
using Microsoft.Xna.Framework;
using Microsoft.Xna.Framework.Graphics;
using Microsoft.Xna.Framework.Input;

namespace ShadersTest {
    // A lot of the code of other shaders was taken and translated to hlsl from shadertoy, so bless those guys!

    internal class Program : Game{
        [STAThread]
        static void Main(string[] args) {
            using (Program g = new Program()) {
                g.Run();
            }
        }

        //Rendering stuff
        private SpriteBatch batch;
        private RenderTarget2D renderTarget;
        private Camera2D camera;

        //Test textures
        private Texture2D texture;
        private Texture2D water;
        private Texture2D blank;
        
        // Effects
        private Effect bg_effect;
        private Effect post_processing_effect;
        private Effect light;

        GraphicsDeviceManager gdm;

        private Program() {
            gdm = new GraphicsDeviceManager(this);

            Content.RootDirectory = "Content";
            gdm.DeviceReset += DeviceReset;
            gdm.PreferredBackBufferWidth = 1920;
            gdm.PreferredBackBufferHeight = 1080;
            Window.AllowUserResizing = true;
        }

        protected override void Initialize() {
            //Shader compilation

            CompileShader("effects\\background.fx", "effects\\compiled\\background.fxb");
            CompileShader("effects\\crt.fx", "effects\\compiled\\crt.fxb");
            CompileShader("effects\\light.fx", "effects\\compiled\\light.fxb");
            base.Initialize();
        }

        int targetGameWidth = 426;
        int targetGameHeight = 240;

        protected override void LoadContent() {
            batch = new SpriteBatch(GraphicsDevice);
            camera = new Camera2D();
            //Loading Textures
            texture = Content.Load<Texture2D>("fire-fox");
            water = Content.Load<Texture2D>("water");
            blank = CreateTexture(GraphicsDevice, 1, 1, pixel => Color.Red);

            renderTarget = new RenderTarget2D(GraphicsDevice, targetGameWidth, targetGameHeight);

            //Loading Effects
            bg_effect = Content.Load<Effect>("effects\\compiled\\background");
            post_processing_effect = Content.Load<Effect>("effects\\compiled\\crt");
            light = Content.Load<Effect>("effects\\compiled\\light");
            
            //Setting up some params
            light.Parameters["LightPositions"].SetValue([new Vector4(0, 0, 0, 0), new Vector4(256, 128, 0, 0), new Vector4(128, 64, 0, 0)]);
            light.Parameters["LightColors"].SetValue([new Vector4(0, 0, 1, 1), new Vector4(1, 0, 0, 1), new Vector4(0, 1, 0, 1)]);
            light.Parameters["LightInfo"].SetValue([new Vector4(0.5f, 100, 0, 0), new Vector4(0.5f, 100, 0, 0), new Vector4(0.5f, 100, 0, 0)]);
            light.Parameters["NumLights"].SetValue(3);
            light.Parameters["AmbientColor"].SetValue(new Vector3(0.5f, 0.4f, 0.7f));

            bg_effect.Parameters["resolution"].SetValue(new Vector2(targetGameWidth, targetGameHeight));
            bg_effect.Parameters["lerp_colors"].SetValue([
                new Vector3(-0.1f, -0.3f, 0.2f), 
                new Vector3(0.4f, 0.2f, 0.15f), 
                new Vector3(0.6f, 0.4f, 0.35f)
            ]);
        }

        protected override void UnloadContent() {      
            //Don't forget to clean after yourself :)
            batch.Dispose();
            water.Dispose();
            texture.Dispose();
            blank.Dispose();
            bg_effect.Dispose();
            light.Dispose();
            post_processing_effect.Dispose();
            renderTarget.Dispose();
        }

        int frame = 0;

        private void DeviceReset(object sender, EventArgs e) {
            //When size is changed update render target and the resolution of our bg
            renderTarget = new RenderTarget2D(GraphicsDevice, targetGameWidth, targetGameHeight);
            bg_effect.Parameters["resolution"].SetValue(new Vector2(targetGameWidth, targetGameHeight));
        }

        protected override void Update(GameTime gameTime) {
            // The time counter
            frame += 1;

            KeyboardState ks = Keyboard.GetState();
            if (ks.IsKeyDown(Keys.Escape))
                Exit();

            //Change bg effect types
            if (ks.IsKeyDown(Keys.D1)) {
                bg_effect.Parameters["type"].SetValue([true, false, false, false]);
            }
            else if (ks.IsKeyDown(Keys.D2)) {
                bg_effect.Parameters["type"].SetValue([false, true, false, false]);
            }
            else if (ks.IsKeyDown(Keys.D3)) {
                bg_effect.Parameters["type"].SetValue([false, false, true, false]);
            }
            else if (ks.IsKeyDown(Keys.D4)) {
                bg_effect.Parameters["type"].SetValue([false, false, false, true]);
            }

            if (ks.IsKeyDown(Keys.F11)) {
                gdm.ToggleFullScreen();
                gdm.ApplyChanges();
            }

            //Simple FPS calculations
            var deltaTime = (float)gameTime.ElapsedGameTime.TotalSeconds;
            var fps = string.Format("FPS: {0}", 1f / deltaTime);
            if (frame%60 == 0) {
                Console.WriteLine(fps);
            }

            //Apply the time for the bg effects
            bg_effect.Parameters["time"].SetValue(frame/60f);

            base.Update(gameTime);
        }

        protected override void Draw(GameTime gameTime) {
            //A shrimple implementation of integer scaling
            //Priorotize height
            float scaleFactorH = Window.ClientBounds.Height / (float)targetGameHeight;
            float scaleFactorW = Window.ClientBounds.Width / (float)targetGameWidth;

            float scaleFactor = scaleFactorH;

            if (targetGameWidth * scaleFactorH <= Window.ClientBounds.Width) {
                scaleFactor = scaleFactorH;
            } else if (targetGameHeight * scaleFactorW <= Window.ClientBounds.Height) {
                scaleFactor = scaleFactorW;
            }

            //Set our render target
            GraphicsDevice.SetRenderTarget(renderTarget);
            GraphicsDevice.Clear(Color.Black);

            //Draw the background
            batch.Begin(0, BlendState.AlphaBlend, SamplerState.PointClamp, null, null, bg_effect, camera.GetMatrix());
            batch.Draw(blank, new Rectangle(0, 0, targetGameWidth, targetGameHeight), Color.White);
            batch.End();

            //Draw other textures
            batch.Begin(0, BlendState.AlphaBlend, SamplerState.PointClamp, null, null, light, camera.GetMatrix());
            batch.Draw(texture, new Rectangle(0, 0, 256, 128), Color.White);
            batch.End();

            GraphicsDevice.SetRenderTarget(null);

            GraphicsDevice.Clear(Color.Black);
            batch.Begin(0, BlendState.AlphaBlend, SamplerState.PointClamp, null, null, post_processing_effect);
            //Draw the render target, centered and with the right scaling WITH cool CRT :0
            batch.Draw(renderTarget, new Rectangle(
                (int)(Window.ClientBounds.Width / 2 - targetGameWidth / 2 * scaleFactor),
                (int)(Window.ClientBounds.Height / 2 - targetGameHeight / 2 * scaleFactor),
                (int)(targetGameWidth * scaleFactor), (int)(targetGameHeight * scaleFactor)), Color.White);
            batch.End();

            base.Draw(gameTime);
        }

        void CompileShader(String path, String name) {
            Process process = new Process();
            process.StartInfo.FileName = "Content\\fxc.exe";
            process.StartInfo.Arguments = "/T fx_2_0 "
                + Environment.CurrentDirectory +
                "\\Content\\" + path + " /Fo Content\\" + name;
            process.Start();
            process.WaitForExit();
        }

        public static Texture2D CreateTexture(GraphicsDevice device, int width, int height, Func<int, Color> paint) {
            Texture2D texture = new Texture2D(device, width, height);

            Color[] data = new Color[width * height];
            for (int pixel = 0; pixel < data.Count(); pixel++) {
                data[pixel] = paint(pixel);
            }

            texture.SetData(data);

            return texture;
        }
    }

    public class Camera2D {
        public float zoom;
        public Matrix transform;
        public Vector2 pos;
        public float rotation;

        public Camera2D() {
            zoom = 1.0f;
            rotation = 0.0f;
            pos = Vector2.Zero;
        }

        public Matrix GetMatrix() {
            transform = Matrix.CreateTranslation(new Vector3(-pos.X, -pos.Y, 0)) *
                Matrix.CreateRotationZ(rotation) *
                Matrix.CreateScale(new Vector3(zoom, zoom, 1)) *
                Matrix.CreateTranslation(new Vector3(0, 0, 0));
            return transform;
        }
    }
}
